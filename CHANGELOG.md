# Changelog

lupp.us has no release tags; an entry here is a merged sprint, in the
shape D65 rules: user-visible changes only, the sprint id named.

## ww14 — 2026-09-03

The ladder lights. The interpreter pin moves to lupin **0.1.25**; the compiler
pin does not move, and that is the whole story of this entry. lupin 0.1.25 was
released against pin `982f857` — wolf **v0.2.4**, the tag itself, the release
this site advertises — so for the first time the two implementations behind
this site are reading one revision of the specification.

**The dark sample lights up, and the gate is what turned the page.** ww13 put
`corpus/typecheck/byte_casts.lu` on the playground menu knowing it did not
run, marked with a note explaining the refusal, and built
`scripts/check-samples.mjs` to hold that note in both directions: an unnoted
entry must answer `exit` or `trap`, a noted one must not. At the new pin the
gate went **red** before anything else did —

    FAIL corpus/typecheck/byte_casts.lu   exit(0)  (noted)
         runs at this pin, and still carries the note that says it does not —
         retire the note in scripts/collect-samples.py

— exit 1, one of thirty-three entries wrong. That red is the retirement
mechanism working: the note came off because CI refused the build, not because
someone remembered a week later. Press Run on **the byte, and its cast
ladder** now and it prints the line its own corpus header claims:

    widen 200 200 | trunc 0 255 0 255 44 | arith 201 400 -1 -200 | order true true true | eq true true

exit 0, no diagnostics, no warnings — the whole D72 ruling in one line: the
widen is zero-extension (200 back, never -56), `256` truncates to 0 and `-1`
to 255 and `300` to 44 with no trap and no `W0401`, arithmetic widens to `int`
first so `200 + 200` is 400, and the comparisons are octet order. All
thirty-three menu entries run or trap on purpose now, and **no sample carries
a note** for the first time since ww13 introduced them.

**The `fail` class is empty.** Re-measured through the module this build
publishes: 282 `phase: run` corpus programs (unmoved — the corpus did not
move), **197 `exit`, 31 `trap`, 54 `unsupported`, 0 `fail`**, against 192 /
31 / 49 / 10 a release ago. Of the ten the interpreter rejected at 0.1.24,
five run or trap now — the cast ladder among them, and `grammar/bom_at_start.lu`,
whose leading `ef bb bf` this release strips the way wolfc does — and five
report `unsupported` by naming the tier that declines them rather than the
type they could not resolve: `fs_write_bytes` and `fs_create_dir_all` do not
exist in this machine, the s39 net tier has no sockets to open in a tab, and
one wants a `List.first` the std subset does not carry. A refusal that names
the right reason is a different fact from a refusal that names the wrong one,
and only one of the two is worth printing on a page.

**The pin lag rule is 0-or-1 now, and the step says which.** The Windows job
has held the gap at exactly one release since ww12, deliberately, so that
lupin catching up would go red rather than quietly falsify /install/ and
/play/. It went red. The step now accepts zero or one, computes which, and
writes the sentence from the measurement — at these pins `lupin reads this
release — the page's sentence holds`, and the run summary's table says `A gap
of 0`. Two is still a red, because two means a lupin release was skipped or a
pin was never bumped. Both pages are rewritten to match: /install/ says the
two commits in `wolf --version`'s second line ARE the same commit at these
pins and that one is the usual gap, /play/ says a disagreement here is now
about the text rather than a lag behind it.

**Nineteen claims re-recorded**, across /play/, /install/,
`scripts/collect-samples.py` and the Windows job — every sentence phrased
"one release behind", the whole "One sample this build refuses" section, the
sample-selection census, and the job's error string, summary line and closing
sentence. The `lupin.exe` link on /install/ and the Windows job's lupin smoke
both follow the pin without a hand edit: the link is a stamped lupin-version
placeholder and the job reads the pinned `Cargo.toml`, so both point at the
0.1.25 asset (5.3 MB, one file, `about 5 MB` still true) with no version
literal to rot. (Writing that placeholder's name literally in this entry is
the trap ww12's finished-dist sweep exists to catch, and it is dodged here
the way ww13 dodged it.) /changelog renders the new entry: **THE BYTE ARRIVES (is36)**.

The two lupin literals /play/ carries on purpose — `v0.1.22` and `v0.1.23`,
about when the observation record started carrying a trapping program's
output — were re-read by hand at this bump and both hold. They are audited
against the *wolf* pin, which did not move, so the allowlist did not force
that reading; wolf-web#8 is still the hole it was, and this is the second
wave in a row it had to be covered manually.

One upstream finding rides along without touching this site: **byte has the
type but not the domain** (wolf-interp#62). `byte` resolves and the casts
hold, but `0..=255` is not enforced where an un-cast `int` flows into a byte
slot — `List[byte].push(256)` stores 256 here where the compilers refuse
`E0401`. All thirty-three menu programs were checked against it and none is
exposed: the ladder truncates by clause (`256 as byte`), and the only other
sample that touches the type is `projects/rpn.lu`, which reads bytes out of
`tok.bytes()` with `b as int` and pushes nothing back in. is37 fixes it.

## ww13 — 2026-09-03

The byte on the page. The pins move to wolf **v0.2.4** and lupin **0.1.24**,
and the release's headline is a breaking change one line wide, so it is on
/install/ rather than only in the changelog. `str.bytes()` yields `byte` now —
an 8-bit unsigned octet — and the first thing anyone does with one is compare
it to a number, which is `E0401`. The page quotes the compiler finishing that
sentence: **"`byte` adopts no literal and takes no `int` implicitly
([type.byte]): widen the byte — `b as int` — or narrow this side with `as
byte`"** — and the Windows job builds that exact program on a Windows runner,
reads the note back, and then builds the line the note names and runs it:
`w is 119`, exit 0. Exit 1 for the refusal, measured rather than guessed, and
the page draws the distinction a learner needs — an ordinary program that does
not compile, not the exit 2 this host's own refusals answer with.

**Unix-domain sockets are the third named refusal on Windows**, new at this
release. `net_listen_unix` compiles here and answers the `unsupported` row BY
NAME rather than a bare `io` failure, which is the difference between a
program that can branch on the host and one that cannot; the limits section's
opener owns its count and now says three. Both halves are measured: the
corpus's own witness runs on the runner for its exact stdout and for the exit
3 it would take if a bind ever failed with a path row, and a second probe
beside it says which branch of that construction this host took, because a
witness that passes vacuously proves nothing about a sentence.

**The playground runs a byte sample that does not run.**
`corpus/typecheck/byte_casts.lu` — the cast ladder, where 256 truncates to 0
and -1 to 255 and the widen is zero-extension — is the thirty-third program on
the menu, and lupin 0.1.24 answers `fail(E0301)` on it at resolve, because
`as byte` names no type that release knows. It is on the menu anyway, marked,
with the reason on the page: the interpreter tagged its byte work at is35 and
the type's producers landed after the wolf release 0.1.24 was built against.
The page promises nothing about when that changes. What holds it honest is a
gate rather than a memory — `scripts/check-samples.mjs` feeds every menu
program to the wasm module the build published and refuses in both directions,
so an unnoted entry must answer `exit` or `trap` and a noted one must not. The
day the interpreter starts running it, CI goes red and the note comes off
because it has to. The whole run set was re-measured through that module at
the new pin: 282 `phase: run` corpus programs, 192 `exit`, 31 `trap`, 49
`unsupported`, and 10 `fail` — a class that was empty a week ago, and exactly
the nine byte programs plus `grammar/bom_at_start.lu`.

**The pin lag is still exactly one release, and the CI step needed no
loosening.** lupin 0.1.24 was released against pin `3befc3e` — wolf v0.2.3 —
while this site advertises v0.2.4, so the gap the step holds at one is one,
and the sentence /install/ and /play/ both write is unchanged. It would have
gone to zero at a lupin 0.1.25; there is no 0.1.25.

**Three sentences had rotted the way ww12's Windows headline did**, each
phrased relative to "the release before this one" and each false the moment
the pin moved: native compilation arriving "one release ago", lupin's
second-opinion distinction being "new at" this version, and the missing arm
archive. All three name the release they mean now — five new version literals,
listed and audited, which is what the allowlist is for.

**And the measured sizes stamp themselves.** The spec and docs pages print how
big each document is so a reader knows what a link costs, and those numbers
were written by hand: four had drifted (spec/01 52 to 53 KiB, spec/02 47 to
48, spec/10 13 to 17 because `byte` is declared in it, spec/11 14 to 16
because the first socket clause is), plus the diagnostics catalogue at 151 to
154. ww12 had re-recorded three of the same class by hand a week earlier. They
work the way version claims have worked since ww07 now — a page names the
document it is sizing in a placeholder and the build fills the number in from
the pinned checkout, refusing when the placeholder names a file the pin does
not carry. (Writing that token literally in this entry is what the finished
dist sweep ww12 added exists to catch, and it caught it.) Fifteen
numbers that can no longer be wrong. The code counts are still by hand and
were re-read at this pin: 136 diagnostics, 33 warnings, both unmoved.

Twenty claims re-recorded in all. /changelog renders v0.2.4, learner-first
paragraph at the top: THE BYTE SHIPS. One finding went upstream the same day —
lupin resolves a cast target by scope lookup, so `as byte` and a misspelled
`as itn` produce byte-identical reports, and the note tells a reader to hunt
for a typo that is not there (wolf-interp#60). The lupin-shaped hole in this
repo's own tripwire (wolf-web#8) had to be dodged again, by spelling a
historical lupin version `v0.1.23` where a bare `0.1.23` would have been
invisible to the checker.

## ww12 — 2026-09-02

The flip. ww11 left one line to change and a runner that had been recording
the "before" every week: three corpus programs — the task layer, channel
transfer, signal reception — run on a Windows box against the published
archive and tabulated, asserted nothing, and waited for a tag. v0.2.3 is the
tag. Against `wolf-0.2.3-x86_64-pc-windows-msvc.tar.gz`, fetched by the URL
the page prints, all three serve: `corpus/conc/spawn_fanout_loop.lu` exits 0
printing `204`, `corpus/conc/message_passing.lu` exits 0 printing nothing,
`corpus/os/signal_loopback.lu` exits 0 printing `reload` — each byte-for-byte
the `stdout=` its own corpus header pins. They are claims now, not a table.

So **/install/'s limits paragraph retires**. The twenty-one by-name refusals
are gone, the `windows-native serves no `spawn`/scopes` transcript comes off
the page, and two named refusals take their place: `wolf build --release`,
exit 2, quoted as the runner printed it (the page had been truncating the
sentence's parenthetical), and external `reload`/`upgrade` delivery, which has
no Windows analog. The second needed care — the page must not say `os.signal`
is unserved when the loopback witness prints `reload` on that host; what a
learner cannot do is send one from another process. The no-toolchain refusal
was re-captured at the tag and has not moved a byte. Three claims in the job
inverted with the prose: `wolf build fanout.lu` now asserts exit 0, an
ordinary `fanout.exe`, and that no refusal names `windows-native` at all.

**The linux-aarch64 hedge retires too.** ww10 wrote "an archive per host that
passes their own unpack-and-run smoke" because v0.2.2 shipped three archives
and threw the arm one away (wolf-lang#213, filed at ww10, fixed here). Four
archives at this tag, and the qualifier is replaced by a measurement rather
than deleted: the Windows job HEADs all four release URLs on every push and
requires 200 and a toolchain-sized body — 68.2 MB linux x86-64, 57.2 MB linux
aarch64, 13.4 MB macOS, 11.5 MB windows. /install/ gained the paragraph that
says what the arm archive serves, which is the checked tier, because that host
still has no native backend.

**The two pins are one release apart, and the site says so.** lupin 0.1.23 was
released against pin `8cda3aa` — wolf v0.2.2 — while the compiler this site
advertises is v0.2.3. `wolf --version` prints both on the runner: `wolf 0.2.3
(wolfgang, pin 3befc3e)`, then `paired with lupin 0.1.23 (reference
interpreter), pin 8cda3aa`. /install/ records it beside the line that explains
that output, the playground records it where the interpreter actually runs
(the honest explanation for a program answering differently in the tab than
under a freshly installed wolf), and a CI step holds the gap at exactly one
release in both directions — when lupin catches up, the sentence goes red
instead of rotting.

The prose sweep at the new pin moved five more claims: the Windows headline
said native build and run were new in the version build.sh stamps into it,
which was true of the release before and would have printed a falsehood the
moment the pin moved; the windows archive is
11 MB, not 10; three spec documents grew (01 50→52 KiB, 11 13→14,
`grammar.ebnf` 9.6→10); the front page's pointer to /install/ now carries the
release's headline; and lupin stops being described as the way to run what the
Windows backend cannot reach, because there is nothing on that host it reaches
that the compiler does not. The four allowlisted version literals were re-read
at 0.2.3 and all four still hold. /changelog renders v0.2.3, learner-first
paragraph at the top: THE ARCHIVE RETURNS.

## ww11 — 2026-09-02

The site tells the parity. The playground moves to lupin 0.1.23, and all three
of that release's visible changes were verified through the rebuilt wasm
before a word was written. A program that traps no longer runs the defers it
had pending: `faults/trap_skips_root_defers.lu` printed
`inner inner-defer before-trap root-defer` in the tab at the previous
pin and prints
`inner inner-defer before-trap` now, which is what all three of the compiler's
lanes print — so the witness joins the sample menu as **a trap runs no
defers**, and a reader can watch the two implementations agree. The reason
nobody could see that disagreement is the second change: through v0.1.22 the
observation record reported `stdout_inline: null` on every trapping program,
so the two machines were record-identical whatever they printed, and the
playground's record note now says so beside the button that shows one. The
third is a kindness a learner meets first: a missing comma used to answer
``expected `}`, found identifier `y` `` and stop, and now finishes the
sentence — "the members of a struct literal are separated — add the comma" —
with a second line, `the comma goes here at 18:25`, pointing at the
zero-width spot where it belongs. The primary span did not move a byte. The
whole run set was re-measured against the new module: 270 conformance
programs, every one in the verdict class it answered in at 0.1.22.

The **compiler** pin does not move. wolf's trunk already serves tasks,
channels and signals on Windows, which will make /install/'s limits paragraph
false the moment it is tagged — but there is no tag, no archive, and nothing
this site's CI could fetch to check a sentence about it, so the page keeps
v0.2.2's measured truth and promises nothing about the next release. What the
Windows job gained instead is the measurement, taken early: three parity
probes — the task layer, channel transfer, signal reception — run on the
runner every week and are **recorded, not asserted**. At v0.2.2 all three
refuse by name with exit 1, each naming the symbol that would not link
(`__wolf_rt_scope_new`, `__wolf_rt_chan_new`, `__wolf_rt_os_signal_listen`)
and the sprint that closes it. When the tag arrives, one line turns those
three rows into claims that can go red.

The prose sweep at the new pin found two claims the menu had outgrown: the
front page and the spec page both said the playground loads "twenty-odd"
corpus programs, and it loads thirty-two.

/changelog re-renders with lupin 0.1.23. One finding went upstream the same
day, against this repo: the version-prose tripwire cannot see a bare
`0.1.22`-shaped literal at all, and audits lupin sentences against the wolf
pin because that is the only clock it reads (wolf-web#8).

## ww10 — 2026-09-02

The learners' page. The pins move to wolf v0.2.2 and lupin 0.1.22, and the
sentence /install/ was built to say last week is retracted: **the compiler
builds and runs native Windows programs now**. `wolf run hello.lu` prints
`hello, wolf` on a Windows box, `wolf build` leaves an ordinary `hello.exe`
you can send to someone who has no wolf at all, and the page leads with that
instead of with a refusal. One thing has to be installed beside it — Visual
Studio Build Tools, "Desktop development with C++" — and rather than
describe what a learner without it sees, the CI job takes the Windows SDK
away from its own runner for the length of one command and quotes the
transcript: exit 2, and a refusal that names the three import libraries and
the workload that carries them. The same job asserts the other half of that
story, which is that no Developer Command Prompt is needed: wolf finds the
toolchain itself from a plain shell with `LIB` unset. What still refuses is
one region of the language rather than a tier — concurrency and the
operating system's edges, twenty-one corpus programs — and the page quotes
that refusal too, with the compiler's own per-host ledger linked at the tag.
`wolf conform-run --checked`, which was the only way to run a program on
Windows through v0.2.1, is demoted to the specialist's tool it always was,
and the paragraph teaching learners to type `.\hello.lu` is gone because
wolf-lang#206 closed at this tag. The reference interpreter has binaries for
the first time, so the section that pointed at nothing now links
`lupin.exe` — one file, downloaded and smoked on the runner beside the
compiler. The playground runs 0.1.22, whose headline is a region with a
budget, and both cap witnesses are in its menu: the boundary that holds and
the breach that traps with the ledger arithmetic in the message. Three
findings went upstream the same morning — v0.2.2 shipped no linux-aarch64
archive because the new dist smoke gates upload on a native tier that host
does not serve (wolf-lang#213), its release page carries no notes at all
(wolf-lang#214), and lupin's comma refusals carry no "add the comma" note
where the compiler's do (wolf-interp#56).

## ww09a — 2026-09-02 — the editor gets its width back

- The playground's two-column split moved from 60rem to 96rem and became
  3:2 in the editor's favor: below that, one column — the editor at the
  page's full width, output beneath. At the old breakpoint the editor got
  ~30rem (about 50 columns), `wrap=off` clipped the rest, and the empty
  output pane looked like reserved editor space (the human's report).
  CSS only; CSP, editor code, and markup untouched.

## ww09 — 2026-09-01

The Windows welcome. The site gains /install/, and its Windows section was
written after the measurement rather than before it: a windows-latest job in
this repo's CI downloads the published archive by the same URL the page
prints, unpacks it with the same `tar`, and asserts every claim the page
makes — word for word, exit code for exit code — on every push and once a
week besides. What that job found is what the page now says. The compiler
runs on Windows up to code generation: `wolf --version`, `wolf --explain`,
`wolf fmt`, `wolf test`, and `wolf conform-run <file> --checked`, which
executes a first program on the compiler's checked machine and prints its
output in the record. `wolf build` and `wolf run` refuse the host by name
with exit 2, and the page quotes that refusal whole instead of paraphrasing
it; native Windows builds are in progress and the page names no date. Two
Windows-shaped facts a learner would otherwise hit blind are on the page
because the runner hit them: a file saved by Notepad is not canonically
formatted until `wolf fmt` rewrites it, and `conform-run` needs `.\hello.lu`
where every other verb takes a bare name (wolf-lang#206). The reference
interpreter is published as a binary for no platform at all, so the page says
so and points at the playground rather than linking a Linux tarball
(wolf-interp#54). The playground's own Windows caveat is now printed beside
its key bindings — Ctrl+Alt+arrows is screen rotation on some laptops — and
the editor's suites run on a Windows runner, where node reports Win32 and
every binding is exercised in its Ctrl spelling.

## ww08 — 2026-09-01

The site catches the wave. The pins move to wolf v0.2.1, lupin 0.1.20 and
the book at bs22, four book sprints and two releases in one turn of the
crank. The playground now runs an interpreter whose `match` arms take a
struct apart by field name, and whose `defer` in a loop body fires at the
end of every turn rather than when the function returns — the transcript
the book's §4.3 now teaches. The book on the site gains the 45-exercise
K&R ladder, chapter 25's first printed section on `wolf publish`, the
corrected `defer` teaching and three pattern exercises: 327 exercises in
the corpus, 278 printed on the pages, each with a solution. /changelog
carries the book's own entries for the first time — bs19 through bs22 —
beside wolf 0.2.1 and lupin 0.1.20. Three prose claims the new pins moved
were re-recorded, and the spec page's `grammar/1` posture is now stamped
from the pin at build time instead of naming a version by hand.

## ww07 — 2026-08-31

The prose catches up. Every version claim on the site was re-recorded
against the pins it already served — eleven stale claims, from "this is
version 0.1.0" under a v0.2.0 toolchain to a spec page missing four
normative documents — and a tripwire now keeps the class at zero:
current-version claims are stamped into the pages at build time from the
pinned checkouts, and every literal version mention must be counted and
re-audited on each pin bump or the build refuses. The site also grew
/changelog: each public project's CHANGELOG.md rendered from the pinned
checkout it was built from, with a repo that has none yet getting a page
that says so instead of a broken link.

## ww06 — 2026-08-30

The site catches up: pins move to wolf v0.2.0, lupin v0.1.18 and the
post-bs19 book, so the playground runs six releases' worth of
interpreter (+10.7% wasm) and diagnostics point at line:col instead of
byte offsets. The editor grows manners — auto-indent, wolf-aware bracket
pairing (interpolation braces pair inside strings), goal columns, and
multi-cursor editing with one-step undo — under a CSP gate that proves
no script source was added to get them.

## ww05 — 2026-08-26

The PDF on the page: the reading page offers the typst-set print edition
for download, rendered from the same pinned book source as the web
pages, with its measured size printed beside the link — and the line
removed entirely when a build has no PDF, so the page never advertises a
file the dist does not carry. Trunk work soon after fixed the page the
fix shipped on: a 0600 file had been 403ing live, and the build now
refuses any dist file nginx cannot read.

## ww00-era — 2026-08-13 to 2026-08-22

The site exists. A landing page, the playground (lupin compiled to
WebAssembly, running conformance-corpus samples entirely in the tab),
the spec and diagnostic catalogues copied from a pinned compiler
checkout, and the book rendered from its own pinned repo — everything
served generated from submodule pins, so no page can claim a version of
wolf that does not exist. CI builds on every push, a link checker walks
the dist, deploys go to lupp.us over a restricted key, and a build
missing a piece refuses to ship unless waived by name.
