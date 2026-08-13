//! The playground's bridge to `lupin`.
//!
//! # What this crate is not
//!
//! It is not an interpreter, and it does not decide anything about wolf. Every
//! verdict, diagnostic, trap and byte of output it hands back came out of
//! `wolf_interp`, the pinned reference interpreter. The crate exists to do two
//! narrow things: move UTF-8 across the wasm boundary, and spell the result the
//! way `lupin run -` spells it at a terminal, so a reader who types a program
//! into a web page and a reader who pipes it into the binary see the same
//! sentence.
//!
//! # The ABI
//!
//! Six exported functions and one convention. A *buffer* is a pointer into
//! wasm linear memory; a *result* is a buffer whose first four bytes are a
//! little-endian `u32` byte length, followed by that many bytes of UTF-8 JSON.
//!
//! | export | takes | gives |
//! |---|---|---|
//! | `lupin_alloc(len)` | a byte count | a buffer the caller fills with source |
//! | `lupin_free(ptr, len)` | that buffer | nothing |
//! | `lupin_observe(ptr, len)` | UTF-8 wolf source | a result: the terminal view |
//! | `lupin_record(ptr, len)` | UTF-8 wolf source | a result: the spec/06 record |
//! | `lupin_version()` | nothing | a result: what built this module |
//! | `lupin_result_free(ptr)` | a result | nothing |
//!
//! The caller allocates, writes, calls, reads, frees. No callbacks, no imports,
//! no host functions at all: the module this crate produces imports nothing,
//! which is why the page needs no JS shim beyond the buffer arithmetic.
//!
//! # Panics are traps
//!
//! `wasm32-unknown-unknown` does not unwind, so `catch_unwind` cannot catch a
//! panic here and this crate does not pretend to. A panic aborts the module and
//! the embedder sees a wasm trap. The page's glue treats that as what it is —
//! an interpreter bug — says so, and throws the instance away, because memory
//! after an abort is not worth trusting.
//!
//! # Coverage
//!
//! `lupin` compiled for wasm declines three tiers it declines nowhere else:
//! tasks, procs, and s40's time trio. All three need a thread or a clock the
//! platform does not have, and a guessed one would make the tiers *look*
//! present while reporting numbers no program should trust. Each comes back as
//! verdict `unsupported` with the reason on the wire, which is the same posture
//! the interpreter takes toward everything outside its scope
//! (`[proto.record.unsupported]`).

use serde_json::{Value, json};
use wolf_interp::diag::Diag;
use wolf_interp::eval::prov::UbFinding;
use wolf_interp::eval::{SchedRequest, Trap};
use wolf_interp::frontend::{self, Observation};
use wolf_interp::protocol::Verdict;

/// The file name `lupin` reports when the program arrived on stdin rather than
/// from a path (`src/main.rs`, `run_run`). The playground is that door: a
/// buffer with no module graph, so the only spelling the invocation has.
const DISPLAY: &str = "<stdin>";

// ---------------------------------------------------------------------------
// the ABI
// ---------------------------------------------------------------------------

/// Hands out a zeroed buffer of `len` bytes for the caller to write source
/// into. Pair with [`lupin_free`].
///
/// A zero-length request gets a dangling-but-aligned pointer; the caller has
/// nothing to write and [`lupin_free`] with the same zero length is a no-op.
#[unsafe(no_mangle)]
pub extern "C" fn lupin_alloc(len: usize) -> *mut u8 {
    if len == 0 {
        return std::ptr::NonNull::<u8>::dangling().as_ptr();
    }
    leak(vec![0u8; len])
}

/// Returns a buffer from [`lupin_alloc`].
///
/// # Safety
///
/// `ptr` and `len` must be exactly what [`lupin_alloc`] returned and was asked
/// for, and the buffer must not have been freed already.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn lupin_free(ptr: *mut u8, len: usize) {
    if len == 0 || ptr.is_null() {
        return;
    }
    unsafe { reclaim(ptr, len) }
}

/// Observes one program and returns the terminal view as a result buffer.
///
/// The shape, all of it lifted from the interpreter's own `Observation`:
///
/// ```json
/// {
///   "verdict": "exit(0)",          // Verdict's Display — the protocol spelling
///   "phase": "run",                // the deepest phase that COMPLETED
///   "exit": 0,                     // lupin's process exit code for this outcome
///   "stdout": "hello, wolf\n",     // every byte, including a trap's partial output
///   "stderr": "",                  // byte-for-byte what lupin writes to a terminal
///   "diagnostics": [ … ],          // {code, span, severity}, protocol shape
///   "warnings": [ … ] | null,      // null is honest-absent, not "none"
///   "detail":   { … } | null,      // the error, with its message and clause
///   "trap":     { … } | null,
///   "ub":       { … } | null,
///   "unsupported": "…" | null,
///   "leaks": 0,
///   "forest": null
/// }
/// ```
///
/// `stdout` is not the record's `stdout_inline`: that field is capped at 4096
/// bytes and, by `[proto.record.fields]`, is only populated for an `exit`
/// verdict. A reader watching a program trap halfway through wants the half it
/// printed, so this door reports the buffer the run actually produced.
///
/// # Safety
///
/// `ptr`/`len` must describe an initialized readable buffer of `len` bytes.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn lupin_observe(ptr: *const u8, len: usize) -> *mut u8 {
    let source = unsafe { borrow(ptr, len) };
    // The unseeded default: strict FIFO, and the record would declare
    // `seeded: false`. A seed selector is a thing the page could grow later;
    // it is not a thing this crate should invent a spelling for.
    let observation = frontend::observe_buffer(source, None, &SchedRequest::Default);
    result(&terminal_view(&observation))
}

/// Observes one program and returns the spec/06 observation record, byte-identical
/// to the line `lupin run - --json` prints.
///
/// This runs the program a second time. The schedule request is the same and
/// the machine has no access to a clock, a filesystem or a network, so the two
/// runs observe the same thing; the page calls this only when a reader asks to
/// see the record.
///
/// # Safety
///
/// As [`lupin_observe`].
#[unsafe(no_mangle)]
pub unsafe extern "C" fn lupin_record(ptr: *const u8, len: usize) -> *mut u8 {
    let source = unsafe { borrow(ptr, len) };
    let (record, _) = wolf_interp::observe_record_stdin(source, &SchedRequest::Default);
    let line = match record.to_json_line() {
        Ok(line) => json!({ "record": line }),
        Err(e) => json!({ "error": e.to_string() }),
    };
    result(&line)
}

/// What built this module: the interpreter's identity fields, verbatim.
///
/// `commit` is `wolf_interp::COMMIT`, the revision the interpreter's own
/// `build.rs` stamped in. `build-wasm.sh` builds from a staged copy with no git
/// directory of its own and points `GIT_DIR` at the submodule's, so the stamp
/// is the interpreter's pin rather than this repository's. It reads `unknown`
/// when there was no gitdir to point at.
#[unsafe(no_mangle)]
pub extern "C" fn lupin_version() -> *mut u8 {
    result(&json!({
        "impl": wolf_interp::IMPL_NAME,
        "impl_version": wolf_interp::IMPL_VERSION,
        "commit": wolf_interp::COMMIT,
        "upstream_pin": wolf_interp::UPSTREAM_PIN.trim(),
        "protocol": wolf_interp::protocol::PROTOCOL_VERSION,
    }))
}

/// Returns a result buffer handed out by any of the observing exports.
///
/// # Safety
///
/// `ptr` must be a result buffer this module returned and not yet freed.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn lupin_result_free(ptr: *mut u8) {
    if ptr.is_null() {
        return;
    }
    let mut header = [0u8; 4];
    unsafe { std::ptr::copy_nonoverlapping(ptr, header.as_mut_ptr(), 4) };
    let len = u32::from_le_bytes(header) as usize;
    unsafe { reclaim(ptr, 4 + len) }
}

// ---------------------------------------------------------------------------
// the terminal view
// ---------------------------------------------------------------------------

/// `lupin`'s process exit code for one verdict.
///
/// The scale is documented on `run_run` in the interpreter's `src/main.rs` and
/// restated here because those constants live in the binary, not the library:
/// a program's own `exit(N)` is N, a static rejection is 2, a trap or a UB
/// finding is 3, `unsupported` is 4.
fn exit_code(verdict: &Verdict) -> u8 {
    match verdict {
        Verdict::Exit(status) => *status,
        Verdict::Trap(_) | Verdict::Ub(_) => 3,
        Verdict::Fail(_) => 2,
        Verdict::Unsupported => 4,
        // Unreachable without a `--phase` cap, which this door does not take.
        Verdict::Pass => 0,
    }
}

/// What `lupin run -` writes to stderr for this outcome, including the trailing
/// newline `eprintln!` adds, and nothing it would not write.
///
/// The `Display` impls doing the work are the interpreter's: `Diag` renders as
/// `CODE: message [clause] at start..end`, a `Trap` as `trap(kind): message
/// [clause] at start..end` with its secondary span appended, a `UbFinding` as
/// its `§7` row over several lines. Reimplementing any of that here would be a
/// second opinion about wording, which is the one thing this crate must not
/// have.
fn terminal_stderr(observation: &Observation) -> String {
    match &observation.verdict {
        Verdict::Exit(_) | Verdict::Pass => String::new(),
        Verdict::Trap(_) => match &observation.trap {
            Some(trap) => format!("{DISPLAY}: {trap}\n"),
            None => String::new(),
        },
        Verdict::Ub(_) => match &observation.ub {
            Some(finding) => format!("{DISPLAY}: {finding}\n"),
            None => String::new(),
        },
        Verdict::Fail(_) => match &observation.detail {
            Some(diag) => format!("{DISPLAY}: {diag}\n"),
            None => String::new(),
        },
        Verdict::Unsupported => format!(
            "{DISPLAY}: unsupported: {}\n",
            observation
                .reason
                .as_deref()
                .unwrap_or("outside this implementation's scope")
        ),
    }
}

fn terminal_view(observation: &Observation) -> Value {
    json!({
        "verdict": observation.verdict.to_string(),
        "phase": observation.phase_reached.as_str(),
        "exit": exit_code(&observation.verdict),
        // Source is UTF-8 by the time it reaches here (a non-UTF-8 program is
        // an E0107 the lexer catches), so a program's own output is too unless
        // it wrote raw bytes; `from_utf8_lossy` is the honest fallback and the
        // replacement character is visible in the page.
        "stdout": String::from_utf8_lossy(&observation.stdout),
        "stderr": terminal_stderr(observation),
        "diagnostics": observation
            .diagnostics
            .iter()
            .map(|d| json!({ "code": d.code, "span": d.span, "severity": d.severity }))
            .collect::<Vec<_>>(),
        // `None` here means the warning analyses never ran, because the program
        // never loaded. An empty array would claim they ran and found nothing.
        "warnings": observation.warnings.as_ref().map(|warnings| {
            warnings
                .iter()
                .map(|w| json!({ "code": w.code, "span": w.span }))
                .collect::<Vec<_>>()
        }),
        "detail": observation.detail.as_ref().map(diag_json),
        "trap": observation.trap.as_ref().map(trap_json),
        "ub": observation.ub.as_ref().map(ub_json),
        "unsupported": observation.reason,
        // is03's leak assertion, and the region-forest invariant. Both are
        // interpreter self-checks; a reader seeing either non-clean has found
        // a bug in lupin, and the page says so.
        "leaks": observation.leaks.len(),
        "forest": observation.forest.as_ref().err(),
    })
}

fn diag_json(diag: &Diag) -> Value {
    json!({
        "code": diag.code,
        "message": diag.message,
        "anchor": diag.anchor,
        "span": [diag.span.start, diag.span.end],
    })
}

fn trap_json(trap: &Trap) -> Value {
    json!({
        "kind": trap.kind.to_string(),
        "message": trap.message,
        "anchor": trap.rule.anchor(),
        "span": [trap.span.start, trap.span.end],
        "secondary": trap.secondary.as_ref().map(|(span, note)| json!({
            "span": [span.start, span.end],
            "note": note,
        })),
    })
}

fn ub_json(finding: &UbFinding) -> Value {
    json!({
        "anchor": finding.anchor(),
        "row": finding.row.id(),
        "clause": finding.row.clause(),
        "licenses": finding.row.optimization(),
        "message": finding.message,
        "span": [finding.span.start, finding.span.end],
        "tag_span": finding.tag_span.map(|span| [span.start, span.end]),
        "tree": finding.tree,
    })
}

// ---------------------------------------------------------------------------
// buffers
// ---------------------------------------------------------------------------

/// Serializes to a result buffer: four bytes of little-endian length, then the
/// UTF-8 JSON.
///
/// A serialization failure is not a thing the caller can be told about through
/// this channel, so it becomes a small hand-written JSON object rather than a
/// panic — the page can render a sentence, and the module stays alive.
fn result(value: &Value) -> *mut u8 {
    let text = serde_json::to_string(value)
        .unwrap_or_else(|_| r#"{"bridge_error":"the result could not be serialized"}"#.to_owned());
    let bytes = text.as_bytes();
    let mut out = Vec::with_capacity(4 + bytes.len());
    #[expect(
        clippy::cast_possible_truncation,
        reason = "a result larger than 4 GiB cannot exist in a 32-bit address space"
    )]
    out.extend_from_slice(&(bytes.len() as u32).to_le_bytes());
    out.extend_from_slice(bytes);
    leak(out)
}

/// Leaks a byte vector to the caller as a bare pointer.
///
/// `into_boxed_slice` makes capacity equal length, which is what lets
/// [`reclaim`] rebuild the allocation from a pointer and a length alone.
fn leak(bytes: Vec<u8>) -> *mut u8 {
    Box::into_raw(bytes.into_boxed_slice()).cast::<u8>()
}

/// # Safety
///
/// `ptr` must come from [`leak`] with this exact `len`, and must not have been
/// reclaimed already.
unsafe fn reclaim(ptr: *mut u8, len: usize) {
    drop(unsafe { Box::from_raw(std::ptr::slice_from_raw_parts_mut(ptr, len)) });
}

/// # Safety
///
/// `ptr`/`len` must describe `len` initialized readable bytes.
unsafe fn borrow<'a>(ptr: *const u8, len: usize) -> &'a [u8] {
    if len == 0 || ptr.is_null() {
        return &[];
    }
    unsafe { std::slice::from_raw_parts(ptr, len) }
}

// ---------------------------------------------------------------------------
// tests
// ---------------------------------------------------------------------------

// These run on the host, not on wasm: the ABI is pointer arithmetic over an
// allocator, and it behaves the same either way. What they are actually for is
// the fidelity claim — that the sentence this crate hands the page is the
// sentence `lupin run -` writes to a terminal. The expected strings below were
// taken from the interpreter's own `Display` impls through `src/main.rs`'s
// `run_run`, and a change to either wording breaks a test here rather than
// quietly making the web page a second opinion.
#[cfg(test)]
mod tests {
    use super::*;

    /// The full round trip a caller makes, through the real exports.
    fn observe(source: &str) -> Value {
        let bytes = source.as_bytes();
        let buffer = lupin_alloc(bytes.len());
        unsafe {
            std::ptr::copy_nonoverlapping(bytes.as_ptr(), buffer, bytes.len());
        }
        let result = unsafe { lupin_observe(buffer, bytes.len()) };
        unsafe { lupin_free(buffer, bytes.len()) };

        let mut header = [0u8; 4];
        unsafe { std::ptr::copy_nonoverlapping(result, header.as_mut_ptr(), 4) };
        let length = u32::from_le_bytes(header) as usize;
        let json = unsafe { std::slice::from_raw_parts(result.add(4), length) }.to_vec();
        unsafe { lupin_result_free(result) };
        serde_json::from_slice(&json).expect("the bridge emits valid json")
    }

    const HELLO: &str =
        "fn main() -> !int {\n    let who = \"wolf\"\n    print(\"hello, {who}\")\n    0\n}\n";

    #[test]
    fn a_clean_program_reports_its_output_and_says_nothing_else() {
        let observed = observe(HELLO);
        assert_eq!(observed["verdict"], "exit(0)");
        assert_eq!(observed["phase"], "run");
        assert_eq!(observed["exit"], 0);
        assert_eq!(observed["stdout"], "hello, wolf\n");
        // A clean run writes nothing to stderr, and the page must not invent a
        // line for it.
        assert_eq!(observed["stderr"], "");
        assert!(observed["detail"].is_null());
        assert_eq!(observed["leaks"], 0);
        assert!(observed["forest"].is_null());
    }

    #[test]
    fn a_trap_is_rendered_the_way_the_terminal_renders_it() {
        let observed = observe("fn main() -> int {\n    var d = 0\n    10 / d\n}\n");
        assert_eq!(observed["verdict"], "trap(div-zero)");
        assert_eq!(observed["exit"], 3);
        assert_eq!(
            observed["stderr"],
            "<stdin>: trap(div-zero): division by zero is defined behavior in wolf: it \
             traps [mem.ub.defined] at 37..43\n"
        );
        assert_eq!(observed["trap"]["anchor"], "mem.ub.defined");
        assert_eq!(observed["trap"]["span"], serde_json::json!([37, 43]));
    }

    #[test]
    fn a_rejected_program_carries_its_code_and_span_on_the_protocol_shape() {
        let observed = observe("fn main() -> !int {\n    let a = 1\n        + 2\n    0\n}\n");
        assert_eq!(observed["verdict"], "fail(E0001)");
        assert_eq!(observed["phase"], "parse");
        assert_eq!(observed["exit"], 2);
        assert_eq!(observed["diagnostics"][0]["code"], "E0001");
        assert_eq!(observed["diagnostics"][0]["severity"], "error");
        assert_eq!(observed["detail"]["anchor"], "gram.amb.newline");
        assert!(
            observed["stderr"]
                .as_str()
                .expect("a line")
                .starts_with("<stdin>: E0001: ")
        );
    }

    #[test]
    fn a_program_that_never_loaded_reports_warnings_as_absent_not_as_empty() {
        // `[proto.record.warn]`: the analyses did not run, so there is no empty
        // array to stand behind. The page distinguishes the two.
        let rejected = observe("fn main() -> !int {\n    let a = 1\n        + 2\n    0\n}\n");
        assert!(rejected["warnings"].is_null());

        let loaded = observe(HELLO);
        assert!(loaded["warnings"].is_array());
    }

    #[test]
    fn a_trap_still_reports_the_output_the_program_managed_to_write() {
        // The reason this crate calls `observe_buffer` rather than reading the
        // record's `stdout_inline`, which is populated only for `exit`.
        let observed =
            observe("fn main() -> int {\n    print(\"before\")\n    var d = 0\n    1 / d\n}\n");
        assert_eq!(observed["verdict"], "trap(div-zero)");
        assert_eq!(observed["stdout"], "before\n");
    }

    #[test]
    fn the_exit_scale_is_the_front_door_s() {
        use wolf_interp::trap::TrapKind;
        assert_eq!(exit_code(&Verdict::Exit(7)), 7);
        assert_eq!(exit_code(&Verdict::Fail("E0001".to_owned())), 2);
        assert_eq!(exit_code(&Verdict::Trap(TrapKind::DivZero)), 3);
        assert_eq!(exit_code(&Verdict::Ub("mem.ub".to_owned())), 3);
        assert_eq!(exit_code(&Verdict::Unsupported), 4);
    }

    #[test]
    fn the_version_export_names_the_interpreter_and_not_this_crate() {
        let pointer = lupin_version();
        let mut header = [0u8; 4];
        unsafe { std::ptr::copy_nonoverlapping(pointer, header.as_mut_ptr(), 4) };
        let length = u32::from_le_bytes(header) as usize;
        let json = unsafe { std::slice::from_raw_parts(pointer.add(4), length) }.to_vec();
        unsafe { lupin_result_free(pointer) };
        let value: Value = serde_json::from_slice(&json).expect("valid json");
        assert_eq!(value["impl"], "lupin");
        assert_eq!(value["impl_version"], wolf_interp::IMPL_VERSION);
        assert_eq!(value["protocol"], 1);
    }

    #[test]
    fn a_zero_length_allocation_round_trips() {
        let buffer = lupin_alloc(0);
        unsafe { lupin_free(buffer, 0) };
        // And the observing door tolerates an empty program: an empty buffer
        // lexes and parses to an empty unit with no `main`.
        let observed = observe("");
        assert!(observed["verdict"].is_string());
    }
}
