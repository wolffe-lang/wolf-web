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
      wasm build has none to give. Four `conc` programs that never actually
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

That leaves 240 candidates at this pin — the programs that actually answer
`exit` or `trap` in the browser build, 66 reporting `unsupported` (the
module-graph programs above, and the tiers a tab cannot serve) and two
answering `fail`, which is the pin lag rather than a tier. Every one of
those numbers is measured by feeding each candidate to the wasm module this
build publishes and reading the verdict back — re-measure on a pin bump
rather than trusting the line. The list below is a spread across the ones
that answer, kept short enough to read in one glance.

A sample may also carry a NOTE, and at some pins one does. The third
element of a `SAMPLES` entry is prose the playground prints beside the
provenance line, and it exists for the case this file's selection rule
cannot otherwise admit: a program the pinned interpreter does not run. That
is not a loophole. `scripts/check-samples.mjs` feeds every listed program
to the wasm module the build publishes and holds the rule in BOTH
directions — an entry with no note must answer `exit` or `trap`, and an
entry WITH a note must not. A note therefore cannot outlive the refusal it
explains: the release that makes the program run turns the gate red, and
the note comes off instead of quietly lying. That is not a hypothetical any
more. `typecheck/byte_casts.lu` carried the only note this file has ever
written, added at the lupin 0.1.24 pin; 0.1.25 landed the byte and the gate
went red with `runs at this pin, and still carries the note that says it
does not`, which is how the note came off. No entry carries one now, and
none has since.

Re-measured at the wolf v0.2.10 / lupin 0.1.31 pins, against the module this
build publishes: 308 `phase: run` corpus programs, 209 `exit`, 31 `trap`, 66
`unsupported` and 2 `fail`. Candidates 240.

That was the prediction, written down before the harness ran, and this time
the INTERPRETER pin stands still: the module is byte-identical to the one the
last pin published, so every movement below is the corpus moving under it.
Twelve programs are new and none is gone; six of the twelve are `phase: run`
and the other six are negatives the compiler refuses, which the census does
not walk. Nine existing programs changed body — `ch.send(v)` becoming
`ch.send(v)?`, because `send` is `() ! {closed, cancelled}` at this release —
and none of the nine changed header, phase or class. Each was placed from the
release notes and the tier rules before anything ran, and the harness agreed
on every one.

  grammar/match_switch.lu            exit(0)       s147, the guarded arm; no range
  conc/chan_send_closed_row.lu       exit(0)       s146, a channel, no spawn
  typecheck/unit_context_discard.lu  unsupported   s146, `scope s { s.spawn(…) }`
  conc/spawn_tail_send_raised_row.lu unsupported   s146, a spawned task body
  grammar/match_range.lu             fail(E0201)   s147, the pin lag
  grammar/match_range_char.lu        fail(E0201)   s147, the pin lag

AT THE lupin 0.1.32 PIN the corpus does not move at all — the compiler pin
stands still — and the interpreter moves instead. The `fail` class empties: the
two range programs above answer `exit(0)` here now, because 0.1.32 mirrors
`[gram.pat.range]`. Predicted before the harness and held on every number:
308 `phase: run` programs, 211 `exit`, 31 `trap`, 66 `unsupported`, 0 `fail`,
candidates 242.

`grammar/match_range.lu` JOINS THE MENU on that verdict, which makes
thirty-six. It was kept off for exactly one pin and for exactly one reason —
an entry that answers `fail` looks broken, which is the rule
check-samples.mjs holds — and the reason expired the day the interpreter
gained the pattern form. `grammar/match_range_char.lu` stays off: it teaches
the same arm over `char`, and the menu is a tour rather than a corpus.

Two programs still part without appearing in any verdict count at all, because
no machine runs them: `rows/negative/row_operand_compare.lu` (E0409 here,
E0401 there) and `typecheck/str_slice_assign.lu` (E0416 here, a tier refusal
there) part by the class of the refusal, and both are wolf-interp#85. The two
range negatives that used to sit beside them —
`grammar/match_range_open.lu` and `rows/match_range_empty.lu` — now agree with
the compiler on both the code and the site, so they are not partings any more.
/play/ names the remaining pair in prose for that reason: at this pin the
verdict table is empty and the parting count is not zero.

The four refusals ww18 called over-determined came apart at ww19 and have
stayed apart: `net_writev` and `net_nodelay` are in this interpreter,
`fs_fstat` is declined in EVERY build of it including the terminal one, and
all four answer `unsupported` in the tab on the tier alone. Reopening the pin
gap did not put the second reason back, because none of the four is a call
this interpreter predates any more.

  net/syscall_first.lu, net/nodelay.lu, net/writev_gather.lu   unsupported
  fs/fstat.lu                                                  unsupported
  net/accept_race.lu                                           unsupported
  strings/to_int.lu                                            exit(0)
  typecheck/byte_casts.lu                                      exit(0)
  os/cpus.lu                                                   exit(0)
  grammar/match_switch.lu                                      exit(0)

The last two are what the page's oldest lupin sentences rest on: 0.1.25 landed
the byte and it has stayed landed, and `os_cpus` answers the `io` row rather
than declining.

Sixteen of the corpus's net programs answer `unsupported` here, unmoved, and
that is every `.lu` file in `corpus/net/`. Fifteen of them decline on the net
tier by name and the sixteenth, `net/accept_race.lu`, reaches for `os_spawn`
first and declines on the process trio, which is a distinction the count on
/play/ does not draw and does not need to.

That count is not written by hand any more. /play/ carries
`__COUNT_netprograms_Word__`, which scripts/stamp-counts.py fills in from the
pinned `corpus/net/`, and scripts/check-samples.mjs takes every file in that
directory through the published module and requires all of them to decline.
The number and the claim are held separately on purpose: counting a directory
is only the right measurement while the whole directory really is declined,
and the page said TWELVE for two releases with nothing holding either half
(wolf-web#17).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

# (corpus path, the label the menu shows, and optionally a note the page
# prints beside the provenance line). Order is the running order: the first
# entry is what the playground opens with. A note means "this build does not
# run this program, and here is why" — see the module docstring, and
# scripts/check-samples.mjs, which holds that meaning in both directions.
SAMPLES: list[tuple[str, ...]] = [
    ("hello.lu", "hello, wolf"),
    ("strings/interp_value_position.lu", "interpolation"),
    ("strings/format_spec_width.lu", "format specs"),
    ("strings/builtin_methods.lu", "string methods"),
    ("strings/to_int.lu", "text to a number, and the row when it is not"),
    ("strings/char_interp.lu", "the char scalar"),
    ("typecheck/byte_casts.lu", "the byte, and its cast ladder"),
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
    ("grammar/match_switch.lu", "match as a switch"),
    ("grammar/match_range.lu", "match on a range"),
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
    for entry in SAMPLES:
        corpus_path, title = entry[0], entry[1]
        note = entry[2] if len(entry) > 2 else ""
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
                # Prose for a program this build does not run. Empty for every
                # sample that does; check-samples.mjs holds both halves.
                "note": note,
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
