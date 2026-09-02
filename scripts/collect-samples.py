#!/usr/bin/env python3
"""Collect playground sample programs from the pinned conformance corpus.

    usage: scripts/collect-samples.py <corpus-dir> <out-dir>

Every program the playground offers is a real corpus program, copied verbatim
from the pinned `upstream/wolf-lang` checkout, header comment and all. The
header is the point: each corpus file states its own expected outcome in a
`//!` directive block, and CI in the compiler repo checks that claim. A reader
who loads a sample gets the program *and* the sentence saying what it is
supposed to do, from the same file, so the page cannot describe a program it is
not showing.

Nothing here is written by hand except the running order. `SAMPLES` names which
corpus paths appear and in what sequence, because a menu ordered
`allow_unknown_code, as_view_consuming, assert_fails, ...` teaches nobody
anything. The bytes come from the corpus.

Selection, and what is left out
-------------------------------

Only `phase: run` programs are candidates: the directive means the program is
expected to execute, and the playground can only execute. Three groups of
`phase: run` programs are deliberately absent, because the interpreter in the
browser reports `unsupported` for them and a menu entry that cannot run is a
menu entry that looks broken:

  corpus/fs, corpus/net, corpus/os/args_cwd, corpus/projects/count
      The filesystem tier (declined by design on every platform) and the s39
      net tier, which the wasm build declines: no sockets in a browser tab.

  corpus/conc (most), corpus/procs.lu, corpus/test/conc_schedules_test.lu
      Tasks and procs. The interpreter gives each task an OS thread, and the
      wasm build has none to give. Three `conc` programs that never actually
      spawn do run (measured against the built module at this pin), and two
      of them are in the list below.

  corpus/comptime, corpus/time
      Compile-time evaluation, which the interpreter has not implemented, and
      the s40 time trio, which needs a clock the browser build cannot reach.

  corpus/os (random, signal, spawn), multi-file module programs
      is18's os tiers decline in the browser the same way: no entropy
      source, no signals, no processes to spawn. And a program whose D59
      module graph names sibling files (`resolve/`, `rows/propagate/`, the
      module-lint witnesses) reports `unsupported` from a stdin buffer,
      which is all the playground has to offer.

That leaves 233 candidates at this pin, of which 186 run, 31 trap on
purpose, and 16 report `unsupported` in the browser build (the module-graph
programs above, and the tiers a tab cannot serve). Every one of those
numbers is measured by feeding each candidate to the wasm module this build
publishes and reading the verdict back — re-measure on a pin bump rather
than trusting the line. The list below is a spread across the ones that
answer, kept short enough to read in one glance.

Re-measured at the lupin 0.1.23 pin: all 270 `phase: run` corpus programs
were fed to the module this build publishes and every one came back in the
same verdict class it answered in at 0.1.22 — 190 `exit`, 31 `trap`, 49
`unsupported` over the whole set, so the candidate counts above are
unchanged. The corpus did not move either (wolf-lang stays at v0.2.2), which
is the other half of why. What DID move is inside two of those verdicts:
`faults/trap_skips_root_defers.lu` still traps, and now prints
`inner inner-defer before-trap` instead of `... root-defer` (wolf-lang#209),
and the record for a trapping program carries its stdout at last
(wolf-interp#55).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

# (corpus path, the label the menu shows). Order is the running order: the
# first entry is what the playground opens with.
SAMPLES: list[tuple[str, str]] = [
    ("hello.lu", "hello, wolf"),
    ("strings/interp_value_position.lu", "interpolation"),
    ("strings/format_spec_width.lu", "format specs"),
    ("strings/builtin_methods.lu", "string methods"),
    ("strings/char_interp.lu", "the char scalar"),
    ("grammar/interp_nested.lu", "strings inside strings"),
    ("memory/region_ambient_ok.lu", "a scratch region"),
    ("memory/region_freeze_ok.lu", "regions as values, and freeze"),
    ("memory/region_infer_list_builder.lu", "inferred regions"),
    ("memory/move_ok.lu", "move, take, copy"),
    ("memory/defer_order.lu", "defer runs backwards"),
    ("memory/exclusivity.lu", "exclusivity, checked at run time"),
    ("memory/region_cap_boundary.lu", "a region with a budget"),
    ("typecheck/receiver_modes.lu", "call-site mut and take"),
    ("typecheck/match_exhaustive.lu", "match, exhaustively"),
    ("generics/first_of_list.lu", "a generic function"),
    ("generics/two_instances.lu", "two instantiations"),
    ("grammar/brackets_generic_call.lu", "an explicit type argument"),
    ("traits/dyn_ok.lu", "traits, and a trait object"),
    ("rows/else_tag_payload.lu", "errors are values"),
    ("rows/eu_main_err_exit.lu", "an error out of main"),
    ("faults/overflow_add.lu", "arithmetic traps (overflow)"),
    ("faults/div_zero_rem.lu", "arithmetic traps (divide by zero)"),
    ("faults/bounds_slice.lu", "a bad slice traps"),
    ("faults/region_cap_breach.lu", "a region over its budget traps"),
    ("faults/trap_skips_root_defers.lu", "a trap runs no defers"),
    ("lints/mut_in_interp.lu", "a warning"),
    ("conc/chan_drain_after_inclusive_loop.lu", "a channel"),
    ("io/eprint.lu", "stdout and stderr"),
    ("os/exit_code.lu", "exit codes"),
    ("projects/rpn.lu", "a calculator"),
    ("projects/wordtree.lu", "counting words"),
]

# A directive line is `//! key: value`; the rest of the `//!` block is prose.
DIRECTIVE = re.compile(r"^//!\s*(check|phase|conforms|member)\s*:\s*(.*)$")


def read_header(source: str) -> dict[str, str]:
    """Read a corpus file's `//!` directives.

    The prose in the same block is deliberately not extracted. It stays in the
    file, where the reader sees it in the editor, and it is written for
    contributors: it cites sprint numbers and internal decision ids that have
    no business appearing as page copy.
    """
    directives: dict[str, str] = {}
    for line in source.splitlines():
        if not line.startswith("//!"):
            # The block is contiguous and comes first, so the first line that
            # is not part of it ends the header.
            if directives:
                break
            continue
        found = DIRECTIVE.match(line)
        if found:
            directives[found.group(1)] = found.group(2).strip()
    return directives


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__.strip().splitlines()[2].strip(), file=sys.stderr)
        return 2

    corpus, out = Path(sys.argv[1]), Path(sys.argv[2])
    if not corpus.is_dir():
        print(f"collect-samples: {corpus} is not a directory", file=sys.stderr)
        return 1
    out.mkdir(parents=True, exist_ok=True)

    index = []
    missing = []
    for corpus_path, title in SAMPLES:
        source_file = corpus / corpus_path
        if not source_file.is_file():
            missing.append(corpus_path)
            continue

        source = source_file.read_text(encoding="utf-8")
        directives = read_header(source)

        # The whole selection rests on this directive. If the corpus moved a
        # program off the run rung, saying so is more useful than shipping it.
        if directives.get("phase") != "run":
            missing.append(f"{corpus_path} (phase: {directives.get('phase', 'absent')})")
            continue

        name = corpus_path.replace("/", "-")
        (out / name).write_text(source, encoding="utf-8")
        index.append(
            {
                "name": name,
                "title": title,
                "corpus_path": f"corpus/{corpus_path}",
                # The program's own claim about itself, verbatim from its
                # header. The page shows it next to what actually happened.
                "check": directives.get("check", ""),
                "phase": directives.get("phase", ""),
                "conforms": [
                    anchor.strip()
                    for anchor in directives.get("conforms", "").split(",")
                    if anchor.strip()
                ],
                "bytes": len(source.encode("utf-8")),
            }
        )

    (out / "index.json").write_text(
        json.dumps({"samples": index}, indent=2) + "\n", encoding="utf-8"
    )

    print(f"  samples: {len(index)} programs from the pinned corpus")
    if missing:
        # Loud, but not fatal: a site with 20 samples instead of 23 is still a
        # site, and the build should not stop for it. The pin moved under the
        # list and someone needs to look.
        print(
            f"  samples: {len(missing)} listed program(s) no longer match the pin "
            f"— update SAMPLES in scripts/collect-samples.py:",
            file=sys.stderr,
        )
        for item in missing:
            print(f"    {item}", file=sys.stderr)
    return 0 if index else 1


if __name__ == "__main__":
    sys.exit(main())
