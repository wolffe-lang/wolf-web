# Changelog

lupp.us has no release tags; an entry here is a merged sprint, in the
shape D65 rules: user-visible changes only, the sprint id named.

This file is rendered to /changelog/site/ from the checkout the build pins,
and the render happens BEFORE the stamps run. An entry that spells one of the
build's placeholder tokens out — the version ones, the KiB ones, the count ones
— therefore has it filled in on the served page and says something else there
than it says here, and one of them stops the build outright. Name the source
in words; do not quote the token.

Because it is served prose, `scripts/check-counts.py` walks this file as a
second root (`--also CHANGELOG.md`, wolf-web#27). Every number word an entry
spells out needs its own line in `scripts/count-allowlist.txt`, keyed on
`CHANGELOG.md`, and those lines are `counted=0` with no clock: an entry
records what one wave measured, and no later pin can make that false. The
audit is not asking you to re-read them. It is making you derive a number
before you serve it.

## ww25 — 2026-09-11

The site takes the rest. No release moves: wolf stays v0.2.10 and lupin stays
0.1.31, and the only clock that turns is the one this repository has never
described in a whole sentence — the book's gitlink, which publishes no version
and so is audited by its revision alone.

**The book grows a chapter and an appendix.** The pin moves to the book's
trunk at `3edba7d`, and with it chapter 33, the serving loop, and Appendix E,
the driver's surface. The chapter reads last in part 4 with a number out of
order, because section numbers are the book's permanent anchors and a late
chapter takes the next free one rather than move everything after it; the
reading page now says that, since a reader who sees a part labelled 18–25 and
then 33 is owed the reason. The appendix is the whole command surface in one
place, replayed from the driver's own help, and the back matter sentence names
it — and names the index, which that sentence had quietly omitted since it was
written.

**All four of the book clock's counts reddened at once, and two of them were
wrong.** Predicted before the audit ran and held: the chapter total moves
thirty-two to thirty-three, the chapters written through move thirty to
thirty-one, and the other two stand — chapter 21 still carries five sections
with two reserved, and part 5 is still six programs and a coda. Nothing else
in the book moved a number the site states: chapter 29 is still reserved
whole, chapter 25 is still one section in, and the colophon still counts two
chapters and five sections against the whole book.

**Does the book's gitlink want a stamp of its own, like the interpreter's?**
Half of one. The interpreter's stamp exists because two pages PRINT a
revision, and that sha was rewritten by hand at every bump while the prose
audit saw no version and the count audit saw no number. No page prints the
book's revision — it reaches a reader only through the version stamp and the
rendered changelog header, both written by the build from the gitlink — and
the revision sweep that lane installed already refuses a git revision typed
into any page, whatever it names. So there is nothing for a revision stamp to
hold. The counts are the other half, and this pass is the argument: of the
four, the chapter total is a pure measurement of the pinned checkout, with no
judgement in it at all, and it is one of the two that moved. That one wants to
be a stamped count off the book's table of contents, the way the corpus
numbers already are. The remaining three stay literals on the book clock,
because each states a reading the book does not publish about itself — which
chapters are written THROUGH, and what counts as a program rather than a coda.
Filed as wolf-web#28.

**wolf-book#1 is closed from both ends** (wolf-web#24). This repository shipped
the book's `css/` out of its theme and allowlisted one dead link on the
duplicated first-chapter page, because the render emitted neither; the book's
own render lane took both fixes, and walks and holds its own links now. Both
workarounds are gone, and the cost of dropping them was measured at each pin
rather than assumed: at the pin before, 46 dead links, of which 45 were pages
asking for a print stylesheet that was not there; at this pin, none, across
1439 internal links and 63 pages. `link-allowlist.txt` is comment-only for the
first time since it was written.

**Every revision this site publishes is seven characters, asked for rather
than inherited** (wolf-web#26). Bare `git rev-parse --short` picks its width
from the object count of the repository being asked, so the three pins in the
version stamp came out at two widths, and every post-deploy check since ww20
has carried an undocumented slice on the compiler's to compare it with a page.
Seven is now spelled out at each of the seven places `build.sh` asks git for a
short revision, and at the deploy's own log line, matching what the
gitlink-derived specification pin, the page stamps and the count audit's book
clock already did by construction; and the build refuses to serve a version
stamp whose revisions are any other width. The post-deploy checks drop their slices. It is
wolf-lang#301's ruling for the development build stamp, one layer out.

**This file is served prose, and the count audit reads it now** (wolf-web#27,
in part). `render-changelog.py` turns it into a page under /changelog/, and
both audits took `site/` as their root, so every number here was held by
nothing — which is how ww24's own entry went out claiming three counts of its
allowlists, two of them wrong, in a paragraph about the discipline of counting.
The count audit takes it as a second root. A changelog entry is the record of
what one wave measured, so every number in it is frozen by construction and
carries no clock; the value is that writing a number into a served sentence
costs an allowlist line, everywhere, which is the moment its author has to
derive it. The version-literal half of that issue stays open and says why: this
file carried thirty-four distinct version literals across a hundred and
fifty-three mentions the day this entry was written, all of them history, and
the version allowlist's grammar requires a clock on every entry — so admitting them would redden the whole file
at every release, and the fix is the frozen-entry idea the count allowlist
already has, spelled for a second file.

## ww24 — 2026-09-11

The site takes the tenth. The pin moves to wolf v0.2.10 and lupin stays
0.1.31, which is the mirror image of the three waves before it. Every entry on
the wolf clock reddened at once: eighteen in the version allowlist covering
twenty-eight literal mentions, four in the stamp allowlist covering seven
release-bound sentences, and six in the count allowlist covering nine counted
occurrences. The nine lupin entries across the same three files held untouched,
and so did the four on the book's clock. All of the wolf ones were re-read; all
but the freshness pair stood.

**The lag reopens at one release.** lupin 0.1.31 was built to `4c60946`, which
is still the commit v0.2.9 was cut at — a tag, and now the tag before the one
this site advertises. So the phrase for zero comes off both pages, the phrase
for one goes back on, and the distance the build stamps returns: fifty-one
commits of the compiler's own history between the two gitlinks. The ancestry
count the windows job has done since ww20 decides all of it, and neither page
writes a revision or a distance by hand.

The census was predicted before the harness ran and held on every number and
every witness. 308 `phase: run` programs, 209 `exit`, 31 `trap`, 66
`unsupported`, 2 `fail`, candidates 240. This time the interpreter pin stands
still, so the published module is byte-identical to ww23's and every movement
is the corpus moving under it: twelve programs are new, none is gone, and nine
more changed body without changing class — `ch.send(v)` became `ch.send(v)?`,
because `send` is typed `() ! {closed, cancelled}` at this release.

Six of the twelve new programs are `phase: run` and each was placed from the
release notes and the tier rules before anything ran. `grammar/match_switch.lu`
and `conc/chan_send_closed_row.lu` exit 0; `typecheck/unit_context_discard.lu`
and `conc/spawn_tail_send_raised_row.lu` decline on the task tier, which is the
tab and not the pins; `grammar/match_range.lu` and
`grammar/match_range_char.lu` answer `fail(E0201)`, which is the pin lag with a
face on it. The other six are negatives the compiler refuses, so the census
does not walk them.

**/play/'s divergence table is back, with two rows.** It was empty at exactly
one pin in this page's history, ww23's, and what refilled it is not the
interpreter falling behind on something it had implemented but the compiler
tagging a new pattern form: `match` gained range arms and lupin 0.1.31 was
built before that text existed, so it stops at the `..` inside a pattern and
says so rather than answering wrongly. wolf-interp#83 is the mirror and the two
rows come off together when the interpreter tags against this release.

The page also says what a table of verdicts cannot. Four more programs part at
this pin and none is a row, because no machine runs any of them: two range
negatives refused at a different site on each side, and two wolf-interp#85
witnesses that part in *which* refusal — E0409 against E0401 on a bare row used
as an operand, E0416 against a tier refusal on a write through a `str` slice. A
page that counted only verdicts would have reported a parting of two and
stopped. The prediction caught the same shape one layer up: the sprint named
four range witnesses as census movers and only two of them are `phase: run`.

**`grammar/match_switch.lu` joins the menu**, which makes thirty-five, and it
is the first menu entry chosen to stand beside a table row rather than away
from it. The two range programs are refused in the tab and the switch is not,
and the difference is exactly what the vintage costs: the guarded arm the
switch turns on is a lowering the compiler gained, not a pattern form, so this
interpreter has always run it.

The front page's three release paragraphs were rewritten for r15's three
rulings — `match` in statement position as the switch a reader expects, E0416
saying a `str` slice is no place instead of the compiler apologising for its
own ledger, and W0601 making a fallible send in a loop body a warned discard
rather than a mismatch. Of the seven release-bound stamped sentences the wolf
clock put up for re-reading, three were rewritten (that paragraph, /spec/'s
01-grammar status line, and /play/'s vintage sentence) and four stood. /spec/
moved with the four documents the release touches. One new number word is
listed for the first time: the seven characters
of a development build's commit stamp, a ruling rather than a measurement, and
counted on the wolf clock because a release is the only thing that could change
it.

The package freshness literals moved WITH the release, which has not happened
before on this page. Read live at the bump: the tap's `wolf` builds tag v0.2.10
at revision `662b14c` and its `lupin` builds v0.1.31, and the AUR carries
`wolf-lang` and `wolf-lang-bin` at 0.2.10-1 beside `lupin` and `lupin-bin` at
0.1.31-1. Had the doors not been closed, the sentence would have said so, which
is the whole reason those two claims are literals and not stamps.

One stamp entry's count drops because a check changed hands. /install/'s
pin-lag sentence no longer names the compiler's version at all — at a gap of
one it names the tag before it — so the stamp allowlist audits one fewer bound
sentence there, and the windows job's page-wide phrase check, which reads the
two gitlinks rather than the prose, is what holds it instead.

## ww23 — 2026-09-10

The site takes the tail. The pin moves to lupin 0.1.31 and wolf stays v0.2.9,
so one clock moves again — six lupin literals, the two release-bound
lupin-stamped sentences and the one live lupin count reddened, and the wolf
entries were held untouched.

**The lag is zero, and this time the pin is a tag.** lupin 0.1.31 was built to
`4c60946`, which is not a revision of the compiler's trunk but the commit
v0.2.9 was cut at and the commit this site pins. The counted gap has been zero
once before, at ww19, and that pin was a release commit too; what is new is
that the interpreter now names the release rather than a development revision
of the trunk past it, so the reserved sentence about a pin that is no release
comes off both pages, the phrase for zero comes back, and the distance the
build stamped at the last two pins is gone because there is no distance to
state. The ancestry count the windows job has done since ww20 prints it: same
commit, zero commits back, and both pages say so.

The census was predicted before the harness ran and held on every number and
every witness. 302 `phase: run` programs, 207 `exit`, 31 `trap`, 64
`unsupported`, 0 `fail`, candidates 238. The compiler pin does not move, so the
corpus is byte-identical to ww21's and ww22's, and exactly one row moved.
`strings/concat_mix_char.lu` went from `unsupported` to `exit(0)`: `+` between
a `str` and a `char` in either order, the last of the five witnesses v0.2.9's
release notes named as still parting, and the row /play/'s divergence table has
carried alone since ww21.

The three other things 0.1.31 does were checked against the corpus rather than
read off the release notes and believed. Two of them are new refusals — a
body whose tail slot is `()` under a declared return type, and a bare fallible
row used as an operand — and either could in principle have turned a running
program into a refused one, or got in front of a tier refusal and turned an
`unsupported` into a `fail`. Neither can here: both are decided from
declarations alone, wolf 0.2.9 refuses both shapes, and every `phase: run`
corpus program is a compiler-accepted program. The third resolves a type
annotation's name at last, which cannot bite a program whose names are all in
scope. `:type` at the prompt has no surface in a page with no prompt.

**/play/'s divergence table is retired, not shortened.** It has listed rows at
every pin this page has had — five at the interpreter's release before last,
one at the last — and with `concat_mix_char` mirrored it has none. A table with
no rows is not a thing to serve, so the page says the parting is none and says
what it measured to know it.

That is a statement about these pins and not a promise, and the page says that
too. The compiler's trunk has ruled range arms in a `match` since this
interpreter tagged, and this build answers E0201 to the witnesses that carry
them. None of those programs is in the corpus v0.2.9 ships, so none of them is
in the census behind the page and none is something a reader can meet with the
compiler /install/ hands them today; the mirror is filed as wolf-interp#83 and
the table comes back the day this site advertises a compiler that carries the
arms. The site cannot pull them forward on its own, either: the zero branch of
the pin-lag gate requires the two gitlinks to be the same commit, so a compiler
pin moved off v0.2.9 to reach the new witnesses reds the job by name.

The package freshness literals were read live and every channel had shipped.
The tap's `lupin` formula builds tag v0.1.31 and the AUR's `lupin` and
`lupin-bin` are at 0.1.31-1, while both compiler packages sit at 0.2.9-1 and
the tap's `wolf` builds v0.2.9. That is the second bump running where the doors
were current before the pin landed here, and it is still the reason those two
claims are literals rather than stamps.

One allowlist line was deleted rather than re-read. /install/'s `v0.2.8` was the
tag the pin-lag paragraph named as the newest release the interpreter had read;
at a gap of zero there is no such tag to name, the sentence is gone, and a
counted literal whose sentence has been deleted is a number that can only
drift.

## ww22 — 2026-09-10

No pin moves. This wave closes the hole ww21 wrote down and leaves the site
saying exactly what it said before, by measurement rather than by hand.

The specification revision the interpreter was built to — the seven characters
/install/ and /play/ print three times between them — was the last fact in the
pin-lag paragraph a person typed. It is no version, so the literal audit cannot
see it; it is no count, so the count audit cannot either; and it was rewritten
by hand at every interpreter bump since the paragraph was written. It is
stamped now, off the interpreter's own gitlink — the same one the distance
beside it is counted from — and the sha is checked against the compiler this
site advertises before it is written, so a page cannot print a revision the
pinned checkout does not carry.

The stamp on its own would have moved the hole one step, because nothing stopped
the next editor from typing the sha back in beside it, which is what happened
four bumps running. So the same pass refuses a git revision written into any
page it sweeps, and it refuses the correct one too: a literal that is right
today is precisely the kind that goes quietly wrong at the next bump. The test
suite plants one and watches the build red. The windows job's pin-lag step,
which already reads that gitlink to count the distance, now requires the stamp
on both pages and reds on a literal there as well, and version.json records the
revision the build measured, so what the site serves can be held against the
build's own answer without asking git anything.

The wasm build script says what it does. Its header opened on a portability
patch and called patching the staged interpreter the normal case; that patch
landed upstream and was deleted on 2026-08-13, and every build since has
reported that there is none. The staging is what the paragraph is about now.
The header also states the toolchain requirement once (wolf-web#14): the staged
version pin governs the build only when `rustc` is rustup's shim, so another
rust ahead of it on PATH defeats the pin silently. The script warns where the
pin is staged, and when the wasm target then turns out to be missing it names
the rust that answered rather than sending the reader after a rustup problem
that is not there.

wolf-web#5 is declined. The alternate multi-cursor chord would take
Ctrl+Shift+arrows from every learner who expects it to extend a selection, to
spare some Windows learners a driver hotkey they can turn off — and /play/'s
note already points at the two paths no driver intercepts. The bindings stand
as ww06 wrote them.

## ww21 — 2026-09-10

The site takes the mirror. The pin moves to lupin 0.1.30 and wolf stays v0.2.9,
so one clock moves: the six lupin version literals, the two release-bound
lupin-stamped sentences and the two live lupin counts reddened, and the nineteen
wolf literals held untouched. That is the per-clock audit column doing the job
it was added for, and it is the first bump where it has had a quiet half to
leave alone.

The census was predicted before the harness ran and held on every number and
every witness. 302 `phase: run` programs, 206 `exit`, 31 `trap`, 65
`unsupported`, 0 `fail`, candidates 237. The compiler pin does not move, so the
corpus is byte-identical to ww20's and every class move is a ruling the
interpreter mirrored. The movers were not read off the release notes and taken
on trust: every `phase: run` file was scanned for the constructs 0.1.30 gains —
a leading `else`, `pop` on an empty list, `get` out of range, `first`, `last`,
the `Closed` spelling — and each hit was placed in its class before the module
was built. Four moved and the scan says why the near misses did not: the two
`overflow_list_pop` witnesses pop a list that is not empty, and the ruling took
the empty case only.

**The `fail` class is empty again.** It has been non-zero at exactly one pin in
this site's history, ww20's, and the two grammar witnesses that put it there are
the two the mirror has just taken. A tab no longer hands back E0005, which is
the code the compiler retired in the release the interpreter was catching up to.

/play/'s divergence table goes from five rows to one, which is what a mirror
catching up looks like from here. `strings/concat_mix_char.lu` is what is left:
`+` between a `str` and a `char`, declined in the tab and open upstream as
wolf-interp#78. The row that came off quietest is `conc/chan_closed_row.lu`,
the one no verdict count could ever see — both machines exited 0 at every pin
and only the printed bytes parted — and it prints `closed` now.
`strings/byte_view_lend.lu` came off for a reason that was never a vintage at
all: it was declined because this machine's `List` had no `first`, and the same
ruling that fixed `pop` gave it one.

The lag is still one release and still not a release-shaped gap. lupin 0.1.30
was built to `2c03ed9`, wolf trunk past the s144 merge, dev-stamped for the same
reason 0.1.29's revision was: the clauses it mirrors do not exist at the newest
tag. So the counted phrase does not move and neither does the reserved
`a development revision`. What moves is the distance — fourteen commits behind
the tag, where the last pin was twenty-four — and the distance is a stamp, so it
re-rendered itself and the windows job's pin-lag step went green on the first
run for the first bump in three. The step that has caught the SOURCE of this
number twice running had nothing to say, because ww20 built it to count by
ancestry and ancestry is what this pin needed.

The revision sha is the one fact in that paragraph no gate holds. It is not a
version, so the literal allowlist cannot see it; it is not a count, so neither
can the other. It appears three times across /install/ and /play/ and all three
were changed by hand. A sha in prose is the next hole of the shape this site
keeps finding.

The package freshness literals were read live and both channels had already
shipped. The tap's `lupin` formula builds tag v0.1.30 and the AUR's `lupin` and
`lupin-bin` are at 0.1.30-1, while both compiler packages sit at v0.2.9, which
is current. That is the exact opposite of ww20's reading one wave earlier, and
it is the whole argument for keeping those two claims literals rather than
stamps: a stamp would have asserted the same thing on both days and been wrong
on one of them.

## ww20 — 2026-09-09

The site takes the line. Pins move to wolf v0.2.9 and lupin 0.1.29, both clocks
in one bump for the first time since ww15, so all 25 version literals, all 11
release-bound stamped sentences and all 14 live counts reddened at once and
every one was re-read.

The front page tells it the way the release does, as three things a reader ran
into and none of them something wolf meant to teach. An aligned `if` chain
whose `else` began its own line was an error, E0005, because the newline after
the `}` ended the statement; a line whose first token is `else` continues the
previous statement now, and E0005 leaves the catalogue. The formatter did not
move, which is the half a reader needs: `wolf fmt` still lays a chain as
`} else {` on one line, so the canonical shape is what it was and the aligned
source formats to it. `to_int`'s error row is spelled `parse` rather than
`NotAnInt` — the one CapCase payload-free mark on the builtin surface, in a
language whose own lint says otherwise — and it is the one change here that can
break a program you already wrote, out loud: a `match` arm naming `NotAnInt` is
refused with a note reading `the cases are: parse`. And a `char` joins a `str`,
because a Unicode scalar appended to text is closed under UTF-8 and has one
rendering, while `str + int` still refuses and the clause now says why. v0.2.8's
three paragraphs came off the page; under this stamp they were false.

The census was predicted before the harness ran and held on every number and
every witness, which mattered more than usual because this time it was not a
cheap prediction. ww19's corpus was byte-identical to ww18's; this one moves —
eight programs added, one deleted, two flipped from `phase: resolve` to
`phase: run` because the compiler now accepts what it used to refuse. Each of
the twelve was placed in its class from the release notes and the tier rules
before the module was built. 302 `phase: run` programs, 202 `exit`, 32 `trap`,
66 `unsupported`, 2 `fail`, candidates 234.

**The `fail` class stops being empty.** It has been zero at every pin this site
has ever measured. `grammar/else_chain.lu` and `grammar/else_default_newline.lu`
exist to pin the layout v0.2.9 admits, lupin 0.1.29 has not mirrored it, and
the tab answers `fail(E0005)` — a diagnostic code this same release retires
from the compiler's own catalogue, so the playground hands back a code /docs/
no longer lists. Neither program is on the menu and neither should be.

The lag is one release, and it is not a release-shaped gap. lupin 0.1.29 was
built to `e9a17cb`, a development revision of the compiler's trunk taken
because the clauses it mirrors did not exist at the newest tag — twenty-four
commits short of the commit v0.2.9 was tagged at and past the tag before it.
So the interpreter has read the first of this release's three rulings and not
the other two: it spells `parse`, and it has not mirrored the leading `else`,
the `closed`/`cancelled` tags, `pop` on an empty list or `str + char`. /play/
tabulates the five programs where that shows with the verdict the tab gives for
each, including the one no verdict count can see: `conc/chan_closed_row.lu`
exits 0 on both machines and prints `Closed` where the compiler prints
`closed`.

That distance is measured rather than written. It is a stamp now, filled in
at build time by a new `speccommits` source that counts commits with git over
the two pinned gitlinks — the first count in the site's scheme whose source is
history rather than a file, which is why the build job now deepens the pinned
compiler checkout that actions/checkout took at depth 1.

The windows job went red over the SOURCE of the number for the second bump
running, and this time the changelog retires as a source altogether. It asked
the pinned lupin CHANGELOG which release the interpreter's pin is, and 0.1.29
has no answer to give, because `e9a17cb` is not one and no sentence can make it
one. The gap is the newest release tag that is an ancestor of that pin now,
counted over the pinned compiler's own history. Two ancestry checks come free
and are asserted: the pin must be a commit the pinned compiler carries, and the
compiler pin must descend from it. Whether the pin is a tag is a second fact
about the same gap and gets the same both-directions prose check the four
phrases have — `a development revision` is reserved vocabulary on /install/ and
/play/ now — and each page must carry the distance stamp exactly when there is
a distance to state.

Two sentences had gone false carrying no version and no count word, which is
the class neither audit can see and the reason the windows job holds prose at
all. /play/ said two of the net calls were newer than this interpreter, which
stopped being true at 0.1.28 and was still on the page a bump later. /docs/
said its code counts were not measured, which stopped being true at ww19, when
they became stamps. Both say what they mean now.

The package freshness literals were read live, and the two channels disagreed,
which is the ordinary state rather than a fault. The tap carries both tags this
release describes; the AUR's two interpreter packages are at 0.1.29 and its two
compiler packages are still building v0.2.8. That is the whole argument for
keeping those two claims literals: a stamp would have asserted, with nobody
looking, that a packager had already pushed.

wolf-web#19 closes. Every python script here runs twice — once on a CI runner
during the PR, once on the deploy host when trunk lands — and those were not
the same interpreter with nothing saying so. The host's version is written down
in one place now and two gates read it: the build job installs exactly that
python before anything else runs, so a PR run is the deploy's rehearsal and all
seven scripts are exercised under it; and `ci-deploy.sh` prints the host's
version beside the one CI rehearsed on and refuses to deploy when they differ.
An upgraded host is a red deploy that names both versions rather than a silent
change of what a green PR means.

## ww19 — 2026-09-09

The site takes the interpreter. Pins move to lupin 0.1.28, and for the first
time the counted lag is zero: 0.1.28 was released against 5c729e8, which is
the commit v0.2.8 was tagged at and the commit this site already pinned. Both
/install/ and /play/ say "the same commit", and neither carries a phrase for
one, two or three releases.

The census was written down before the harness ran and held on every number.
293 `phase: run` corpus programs, 200 `exit`, 31 `trap`, 62 `unsupported`, 0
`fail`, candidates 231, identical to the pins before these. It was a cheap
prediction to make: the compiler pin does not move at this bump, so the corpus
is byte-identical and only the module in the tab changes. wolf-interp#69 is
the one item in the release that could have moved a verdict, since it reparses
`str.to_int` as the `i64` the type is, and the corpus witness does not reach
it. wolf-lang held the overflow input in its own crate tests while the two
implementations disagreed, so `strings/to_int.lu` shows the i64 extremes and
nothing outside them, and it exits 0 here as before.

Closing the gap changed nothing about what the playground declines, which is
what ww18 said would happen and what both pages now say instead of leaving a
reader to infer it. `net_writev` and `net_nodelay` are in this interpreter and
`fs_fstat` was never a question of age, so all four witnesses still report
`unsupported` in the tab. A browser has no sockets and this interpreter opens
no files anywhere. Those refusals had two reasons at once while the pins were
apart and one of them has gone.

Five literals reddened on the lupin clock rather than the four this pass
expected. The four historical ones on /play/ hold, and `byte_casts.lu` still
exits 0, so "0.1.25 closed that and it has stayed closed" is still a true
sentence. The fifth is /install/'s package freshness claim, and it is a claim
about somebody else's repository, so it was read live: the AUR has `lupin` and
`lupin-bin` at 0.1.28-1 and the tap's formula builds tag v0.1.28. The doors
were already current, which is the opposite of the ww18 reading and the reason
that sentence is a literal instead of a stamp.

One sentence on /play/ had gone false while carrying no version at all. The
`to_int` sample "could not have been on the menu at the last pin", which
stopped being true the moment those became the last pins. It says what it
means now.

The windows job stopped the build before any of it, over its own defect rather
than the site's. It read the interpreter's specification pin out of a sentence
("Released against pin `x`, wolf-lang **vY**"), and 0.1.28 does not write that
sentence. wolf-interp records the pin as a submodule gitlink, which cannot be
worded differently, so that is where it is read now; the changelog is still
consulted, but only to say which release that commit is, and it has to name
that commit rather than some other pin in the same entry. A counted gap of
zero also gets proved outright now: the phrase the pages carry says "the same
commit", so the two gitlinks have to be it.

Every count in the prose is held by something (wolf-web#17). Eight numbers
were written as English words with no gate anywhere, and one of them was
wrong: /play/ said twelve of the corpus's net programs were declined here from
ww16 to ww18, when thirteen was already the truth and it is sixteen now. Five
of the eight come off something a build can measure and are stamped from it,
the way file sizes have been since ww13 — the diagnostic and warning code
counts off the pinned documents' own headings, the net count off the pinned
`corpus/net/`, the menu count and the front page's "thirty-odd" off the sample
index the build wrote. A placeholder names a source and a spelling, because
the pages spell a number three ways and all three have to come off one
measurement.

The other three are a reading rather than a measurement: the tiers the browser
build declines, the things a Windows program can still reach, the rows the
native lane skips. Those are literals in `scripts/count-allowlist.txt`, which
lists every number word in the site's prose with a total and says how many of
its occurrences a pin bump can still move. A live one carries an `audited-at`
and reddens at the bump, so it is re-read against the thing it counts. There
are three clocks now, because /reading/'s chapter counts move with the book,
which publishes no version and so rides its pin. The frozen ones carry no
clock at all, which the file requires rather than permits.

Counting a directory is only the right measurement while the whole directory
behaves the way the sentence beside it claims, so `check-samples.mjs` takes
every program in `corpus/net/` through the module the build publishes and
requires all sixteen to be declined. The count and the claim are held
separately, because the count was wrong for two releases and the sentence
around it was not.

## ww18 — 2026-09-09

The site takes the first chapter. Pins move to wolf v0.2.8; lupin holds at
0.1.27 for the third release running, and this is the bump where that starts
to cost something.

The front page tells it the way the release does, learner first. Chapter 1 of
the book asks a string for a number twice, and until v0.2.8 the compiler
refused that call, so the first non-trivial string method a learner met was
also the first program that would not build. `str.to_int() -> int !
{NotAnInt}` is in the builtin set on both tiers now, spelled the way the
reference interpreter has always spelled it, and text it cannot read is a row
your program can branch on rather than a trap. At the other end of the
language a parking call in the net family tries the syscall before it waits,
so a read on a socket the program's own `net_wait` just reported ready touches
no lock handshake, no condvar and no `kevent`. lobo went from 53.3 to 21.2
microseconds a request on one box in one session, and the page says the thing
that matters about that pair: other lanes were working on the machine, the
benchmark tool refused both sets under its own quiet-rig rule, and neither is
an entry in lobo's ledger. What the two share is the box, the hour and the
load, so the ratio is the claim and the score is not.

Six predictions, six holds. The class of every new corpus witness was written
down before the harness ran, and the harness agreed: `net/syscall_first.lu`,
`net/writev_gather.lu`, `net/nodelay.lu` and `fs/fstat.lu` answer
`unsupported`, `strings/to_int.lu` exits 0, and `rows/to_int_not_an_int.lu`
exits 1 carrying `NotAnInt` out of main, which is the `exit` class and not
`trap`. The aggregate landed on the predicted numbers too: 293 `phase: run`
programs, 200 `exit`, 31 `trap`, 62 `unsupported`, 0 `fail`, candidates 229 to
231.

Worth saying why the four refusals are over-determined, because the two
reasons come apart at the next interpreter release. Three of them are tiers a
tab cannot serve, and the filesystem tier is declined in every build of the
interpreter including the terminal one. They are also calls this interpreter
predates. When lupin catches up they stay `unsupported` on the tier alone.

The menu is thirty-four. `strings/to_int.lu` joins it, and the reason runs
backwards from the usual one: the interpreter has answered `str.to_int` all
along, so the program the tab could always have run is the one that only just
started compiling. Every other release has moved the compiler ahead of the
playground.

And the count that no gate held was wrong. /play/ has said twelve of the
corpus's net programs answer `unsupported` since ww16, and thirteen was
already the truth when it said it. Sixteen now, measured rather than
incremented. The census exists to be re-measured and this is what re-measuring
is for; a number written by hand beside numbers that are gated reads exactly
as trustworthy as they do, and is not.

The lag is three, and it has teeth the last two did not. v0.2.6 and v0.2.7
moved no language surface, so an interpreter a release or two back still
answered every program the compiler did. v0.2.8 adds four calls the pinned
interpreter predates, so a program using `net_writev`, `net_nodelay` or
`fs_fstat` compiles from the archive and is declined in the playground, and
that is the pin lag rather than a disagreement about the language. Both pages
say so now instead of leaving a reader to infer it.

The windows step stopped the job before any of that, which is what it is for.
The gap counter ww17 built has prose for a closed set of gaps, it counted
three, it found no sentence for three on either page, and it named what was
missing rather than guessing. The phrase went into the table after the
paragraphs were written. One wrinkle came out of it and is recorded beside the
table: those phrases are reserved vocabulary on /install/ and /play/, because
the absent-phrase half of the check is page-wide, and the packaging paragraph
below wanted to say "one release" about something else entirely.

/install/ names what the doors carry, twice in one sprint. ww17 wrote the
package freshness claim as counted literals rather than stamps, on the grounds
that a stamped claim would re-render with the new number at the next bump and
assert, with nobody looking, that a packager had already pushed. Both literals
reddened at this pin. The live AUR and the live tap were read and every
compiler package was still at v0.2.7, so the page said so. Two hours later the
packaging landed, the channels were read again, and the page says v0.2.8. A
stamp would have been accidentally right the second time and quietly wrong the
first, which is the whole argument for the literal: it is a claim about
somebody else's repository, and the only way to know is to look. What stays on
the page is the process fact rather than the state, since a release and its
packaging are separate acts and do not land in the same minute.

One thing this pass nearly got wrong. The v0.2.8 release was still a DRAFT
when the pin was taken, with two of its four archives uploaded, so for a few
minutes the front page's "four archives" and /install/'s Windows download link
named files that did not exist. The release finished publishing before
anything was committed and all four are there. The site's rule is that a page
cannot claim a version of wolf that does not exist, and a tag is not the same
event as a release.

## ww17 — 2026-09-09

The site takes the pairing. Pins move to wolf v0.2.7; lupin holds at 0.1.27,
which is the whole shape of this bump. The compiler tagged and the interpreter
had no reason to.

What v0.2.7 is. `wolf --version` prints a second line naming the lupin release
the compiler is differentially tested against, and that line has one job, which
is to be true. It stopped being true when the interpreter published 0.1.27 and
the compiler's stamp still said 0.1.26. The gate that exists to catch that did
catch it, on every machine in the house at once and on none of the six CI jobs,
because the comparison needs a lupin binary standing beside the compiler and no
runner had one. The release re-measures the pairing against the interpreter as
released and gives the linux job the pinned lupin release archive, fetched by
the digest the release page reports and checked against the bytes that arrive.
No language surface moved. The front page carries the story and nothing below
it moves for it.

The census did not move, which was the prediction. 287 `phase: run` corpus
programs, 198 `exit`, 31 `trap`, 58 `unsupported`, 0 `fail`, candidates 229,
every number identical to ww16's. The prediction was cheap to make and worth
making anyway: no corpus file was added or removed between the two tags, the
only corpus edit is a `conforms:` tag and a comment on
`corpus/test/conc_schedules_test.lu` (a program the playground already
declines), and the module in the tab is unchanged because lupin did not tag.
The numbers were re-measured through the published module rather than reasoned
about, because the rule this file keeps is that they are read, not glanced at.

Thirteen literals reddened, every one of them on the wolf clock, and the four
lupin entries stayed green because 0.1.27 is still 0.1.27. This is the first
bump where the two clocks disagreed, which is what ww15 built them for. Nine
release-bound placeholder sentences reddened beside them (ww16), and four of
the nine were false.

The four. On the front page, "At (the wolf stamp) a loser comes back inside the
budget its `net_deadline` armed" was v0.2.6's fair accept rendering under
v0.2.7; it names v0.2.6 now. On /install/, "the fair accept (the wolf stamp) is
named for is here too" was the same sentence one page over. On /spec/, document
11's "at (the wolf stamp) it states what those hands actually see
(`[os.net.accept]`)" was the third copy of it. Document 05's was different and
more interesting: "at (the wolf stamp) the clause caught up to the practice"
was true of v0.2.6, where four namespaces the documents were already publishing
in got appended to `[conf.anchor.ns]`, and false at v0.2.7, where the register
moved again in the opposite direction. 07-schedule-points.md had been declaring
seven `[sched.*]` anchors that no register carried, so no extractor read the
document and no gate held an opinion about it, while the native runtime cited
four of the seven from live scheduler code. The page says both halves now, and
says the clause is checked in both directions.

The lag is two, and the step that measures it was wrong about why. The windows
job has held the pin lag since ww11 and accepted zero or one since ww14, with a
comment saying a lag of two means a lupin release was skipped or a pin was
never bumped. Neither happened. The compiler tagged twice (v0.2.6, v0.2.7)
while the interpreter held, because a pairing re-stamp gives an interpreter
nothing to catch up to. So the ceiling is retired. The step counts the gap as
the distance from the advertised release back to the one lupin names, over the
pinned CHANGELOG's own ordering, and a gap the pages have no words for stops
the job instead of being called a skipped release.

And the number is now held against the prose, which is the half neither audit
can see. The lag is stated three times across /install/ and /play/, and the
third of the three, "one release behind the compiler's at these pins", carries
no version literal and no placeholder at all. Both audits were green over it
while it was stale, through this bump and, going by the sentence itself, the
one before. The step requires the phrase for the counted gap on both pages and
the phrases for the other gaps on neither, so a paragraph left unrewritten
stops the job and says which page it is on.

/install/ says how the doors open. Two channels carry wolf and the project
publishes both, and until now the page mentioned neither. Homebrew wants
`brew trust wolffe-lang/wolf` before `brew tap wolffe-lang/wolf && brew install
wolf`, and the page says so because skipping the trust line produces an error
that is not true: Homebrew declines to load formulae from an untrusted
third-party tap and reports the refusal as `invalid syntax in tap!`, which is
its generic wording for a tap it would not read. Both formulae parse. The tap
carries `wolf`, `lupin` and `lobo`. On the AUR the packages are named for the
language, because `wolf` there is Return to Castle Wolfenstein and has been for
years: `wolf-lang` and `wolf-lang-bin`, `lupin` and `lupin-bin`, `lobo-bin`.
The freshness claim (all eight packages across the two channels named their
upstream's latest, v0.2.7 for the compiler and 0.1.27 for the interpreter) is
written as counted literals rather than stamps, one on each clock. A stamped freshness claim would re-render with the
new number at the next bump and assert, with nobody looking, that a packager
had already pushed; as literals they red and someone reads the live channel.

Filed upstream, wolf-lang#264. v0.2.7's own CHANGELOG entry documents #253 and
nothing else, but the tag also carries the s139 admission above (#246) and the
s140 driver work: a real `wolf --help` on stdout at exit 0 with per-verb help,
a man page and shell completions, a compile-failure footer that names the code
it actually reported, and a `use std.…` miss that says no standard library is
configured. Four of those issues are still open. The site renders that
CHANGELOG from the pinned checkout, so /changelog/wolf/ now publishes a v0.2.7
entry with two thirds of the release missing, and nothing on this side can fix
it.

## ww16 — 2026-09-07

The site takes the accept. Pins move to wolf v0.2.6 and lupin 0.1.27, and
the front page tells v0.2.6's story instead of listing it.

The class the tripwire could not catch now has a rule. The ww15 pass found
two sentences falsified *by the version stamp itself*: a placeholder is exempt
from the literal allowlist by construction, so a page that renders "byte
arrived at this release" becomes false the moment the stamp moves, with
nothing anywhere to notice. `scripts/stamp-allowlist.txt` generalizes the two
hand fixes. It enumerates every placeholder occurrence with a total and how
many of them are release-bound (true only of the release the stamp names), and
a file with a bound one carries an `audited-at` the pin bump moves past as it
does for a literal. The clock is the placeholder's own name, which caught a
hole in the older half: the pin-lag paragraph reads "lupin *(the lupin stamp)*
was released against v0.2.5", whose only literal rides the *wolf* clock, so a
lupin-only release would have falsified the sentence without ever re-reading
it.

Six sentences were wrong at this bump, and only two carried a version
anywhere. /install/ "because *(the wolf stamp)* is a release about writing
servers" and /spec/ "at *(the wolf stamp)* it gained what a serving loop
needs" were both true of v0.2.5 and both rendered under v0.2.6. /install/ "the
call *the release* is named for" reads the stamp with no version in it at
all. /install/ "it was zero a release ago" and /play/ "the gap was zero one
release ago" were true when the ww15 pass wrote them and false a release
later, because the lag has been one for two releases now. /play/ "that was not
true two releases ago" counted lupin releases from the stamp and drifts every
bump. All six are literals the allowlist counts. All twelve pre-existing
literals went red at the bump, both clocks at once, and every one was re-read
at the tag.

The lag is one and the rule computed it. lupin 0.1.27 reads pin `6ade878`
(wolf v0.2.5) while the site advertises v0.2.6, so ww14's "the two commits
ARE the same commit" is false again and both pages say one release apart. The
Windows job's 0-or-1 step printed it.

The accept, explained for a stranger. A server in wolf is several hands on
one listening socket; every arrival wakes more than one and exactly one takes
it. Through v0.2.5 a loser then parked in a blocking `accept(2)` with its
deadline already spent, until the *next* connection: microseconds on a busy
server and on a quiet one never. Now it comes back inside the budget its
`net_deadline` armed, and nothing in `net_accept`'s signature moved. Both
numbers on the page are measured, and the page says what they were measured
on. The compiler holds at ~30,000 req/s before and after (three hands,
`ab -n 6000 -c 32`, macOS arm64; under load the fix buys nothing), and lobo
deleted its ten-millisecond accept turn, re-run as an A/B in one session on
macOS 15 arm64 with 18 cpus: 12,866 → 23,663 req/s at three hands and
9,554 → 38,961 at eighteen on keepalive. `[conf.anchor.ns]` and #239 get a
line on /spec/ and nothing on the front page.

The census was re-measured and the prediction half held. 287 `phase: run`
corpus programs, 198 exit, 31 trap, 58 unsupported, 0 fail, candidates
228 → 229. `net/accept_race.lu` is `unsupported` as predicted, but the
aggregate was not: `os/cpus.lu` came *off* the unsupported rung, because lupin
0.1.27 registers `os_cpus` and the call no longer fails to resolve. It still
cannot be answered in a tab. What comes back is the `io` row, which
`[os.cpus]` requires of a host that cannot answer, in place of a silent 1, so
the program exits 0 printing `answered false`. Verdict `exit`, and the menu
stays at thirty-three, because a sample shown beside a header it contradicts
looks broken.

And /play/ undercounted what it declines: "five tiers" omitted `os_random`
and `os_signal_listen`, both of which report `unsupported` here and serve at
a terminal. The page says seven now, with the two named (wolf-web#13).

## ww15 — 2026-09-06

The tripwire sees lupin. `scripts/check-version-prose.py` has audited the
site's version prose since ww07 (every literal allowlisted, counted, and
re-read when the pin moves past its audit), with a lupin-shaped hole in both
halves, filed as wolf-web#8 at ww11 and covered by hand at ww11 and again at
ww14. That is two waves of manual work, so this wave fixed the rule first and
proved it before taking a pin.

The audit names its clock. The checker reads two pins now, wolf's CHANGELOG
heading and lupin's `Cargo.toml` version (the same two `build.sh` already
derives), and an allowlist entry says which one audits it: `audited-at-wolf=`
or `audited-at-lupin=`. The proof is the shape that cost the hand coverage.
With the lupin pin moved and the wolf pin held, on ww14's tree with its
checker and its allowlist verbatim, the old rule exits 0. This one exits 1:

    version prose: play/index.html: '0.1.22' was audited at lupin 0.1.25, the
    lupin pin is now 0.1.26 — re-read the sentence, then re-stamp its
    audited-at-lupin

Both sentences were re-read against 0.1.26 and both hold.

And the regex sees a bare `0.1.x`. It matched only `v`-prefixed literals, so
`lupin 0.1.22` (the spelling the site uses everywhere else, since the stamped
placeholder renders without a `v`) was invisible: a claim about an old lupin
could be written into a page and fossilize with nothing to catch it. The ww11
pass worked around that by spelling `v0.1.22`. That workaround is retired;
/play/ spells both literals bare now, and with them deleted from the allowlist
the old checker still reports a clean run while this one names them. The
widened rule found something on its first pass, too: `Rust 1.97.1` on the
front page, a toolchain claim the site has carried unaudited. It has a line
now, on the wolf clock, and the v0.2.5 bump forced its first re-reading.

The pins move to wolf v0.2.5 and lupin 0.1.26. Six allowlisted literals went
red at the wolf bump and every one was re-read at the tag. Two more sentences
would have been falsified *by the stamp*, the class no tripwire catches,
because a placeholder is exempt by construction: /install/ and /spec/ both
said `byte` arrived at this release and the unix-domain clause was new at it.
Both arrived at v0.2.4, and both say so as counted literals now. The pin lag
is one again: lupin 0.1.26 reads `982f857`, wolf v0.2.4, while the site
advertises v0.2.5, so ww14's "the two commits ARE the same commit" is false
and both pages say one release apart. The Windows step stayed as it was; the
ww14 pass made it 0-or-1 and it computes which.

Five named refusals on Windows, not three. wolf v0.2.5 is THE SERVER HAS
CORES (s137), and this is the host where a prefork server is written a
different way. `reuse_port` answers the `unsupported` row, and the refusal is
the designed behavior: Windows has no `SO_REUSEPORT`, and `SO_REUSEADDR` is a
false synonym that lets any process take a held port. Measured on a runner,
two sockets carrying it bound one port and all sixteen dials went to the
first bound, none to the second, so a worker that thought it had joined a
group would sit idle forever. A descriptor handed across a spawn is missing
twice over: the `SOCKET` does not cross the spawn the runtime performs, and a
`SOCKET` is not the small stable number `[os.proc.inherit]` hands over by
position. The page says what serves in the same breath, because a section
listing only refusals would describe a worse host than the one a learner has:
`net_wait` is the one s137 clause that names no refusal anywhere, `os_cpus`
answers, and `net_listen_with` without the option is `net_listen` with a
backlog hint. The Windows job holds all of it: four s137 corpus witnesses run
on the runner for their pinned stdout with the exit-3 guard that catches a
refusal arriving as the *wrong* row, two probes saying which branch this host
actually took, and a third holding the positive half.

The census re-measured, and the corpus moved for the first time in two
releases. Through the module this build publishes: 286 `phase: run` corpus
programs (282 a release ago; s137 added `net/wait_readiness.lu`,
`net/reuse_port.lu`, `net/inherit_listener.lu` and `os/cpus.lu`), 197
`exit`, 31 `trap`, 58 `unsupported`, 0 `fail`. All four new programs answer
`unsupported`, so the candidate count is unchanged at 228: three want sockets
a tab cannot open and the fourth wants the machine's core count, which is
is18's os tier declining in the browser the way `os/random` already does.
The is37 byte domain moved no menu entry's class: thirty-three entries,
each in the class the page claims for it, none carrying a note, the cast
ladder still `exit(0)`. /changelog renders both new entries, THE SERVER HAS
CORES and THE BYTE HAS A DOMAIN (is37).

## ww14 — 2026-09-03

The ladder lights. The interpreter pin moves to lupin 0.1.25; the compiler
pin does not move, and this entry follows from that. lupin 0.1.25 was
released against pin `982f857` (wolf v0.2.4, the tag itself, the release this
site advertises), so for the first time the two implementations behind this
site are reading one revision of the specification.

The dark sample lights up, and the gate turned the page. The ww13 pass put
`corpus/typecheck/byte_casts.lu` on the playground menu knowing it did not
run, marked with a note explaining the refusal, and built
`scripts/check-samples.mjs` to hold that note in both directions: an unnoted
entry must answer `exit` or `trap`, a noted one must not. At the new pin the
gate went red before anything else did:

    FAIL corpus/typecheck/byte_casts.lu   exit(0)  (noted)
         runs at this pin, and still carries the note that says it does not —
         retire the note in scripts/collect-samples.py

Exit 1, one of thirty-three entries wrong. That red is the retirement
mechanism working: the note came off because CI refused the build. Press Run
on *the byte, and its cast ladder* now and it prints the line its own corpus
header claims:

    widen 200 200 | trunc 0 255 0 255 44 | arith 201 400 -1 -200 | order true true true | eq true true

exit 0, no diagnostics, no warnings, and the D72 ruling in one line: the
widen is zero-extension (200 back, never -56), `256` truncates to 0 and `-1`
to 255 and `300` to 44 with no trap and no `W0401`, arithmetic widens to `int`
first so `200 + 200` is 400, and the comparisons are octet order. All
thirty-three menu entries run or trap by design now, and no sample carries a
note for the first time since the notes were introduced at ww13.

The `fail` class is empty. Re-measured through the module this build
publishes: 282 `phase: run` corpus programs (the corpus did not move), 197
`exit`, 31 `trap`, 54 `unsupported`, 0 `fail`, against 192 / 31 / 49 / 10 a
release ago. Of the ten the interpreter rejected at 0.1.24, five run or trap
now (the cast ladder among them, and `grammar/bom_at_start.lu`, whose leading
`ef bb bf` this release strips the way wolfc does), and five report
`unsupported` naming the tier that declines them instead of the type they
could not resolve: `fs_write_bytes` and `fs_create_dir_all` do not exist in
this machine, the s39 net tier has no sockets to open in a tab, and one wants
a `List.first` the std subset does not carry.

The pin lag rule is 0-or-1 now, and the step says which. The Windows job has
held the gap at one release since ww12, so that lupin catching up would go
red instead of quietly falsifying /install/ and /play/. It went red. The step
now accepts zero or one, computes which, and writes the sentence from the
measurement: at these pins `lupin reads this release — the page's sentence
holds`, and the run summary's table says `A gap of 0`. Two is still a red,
because two means a lupin release was skipped or a pin was never bumped. Both
pages are rewritten to match: /install/ says the two commits in
`wolf --version`'s second line ARE the same commit at these pins and that one
is the usual gap, /play/ says a disagreement here is now about the text
instead of a lag behind it.

Nineteen claims re-recorded, across /play/, /install/,
`scripts/collect-samples.py` and the Windows job: every sentence phrased
"one release behind", the whole "One sample this build refuses" section, the
sample-selection census, and the job's error string, summary line and closing
sentence. The `lupin.exe` link on /install/ and the Windows job's lupin smoke
both follow the pin without a hand edit: the link is a stamped lupin-version
placeholder and the job reads the pinned `Cargo.toml`, so both point at the
0.1.25 asset (5.3 MB, one file, `about 5 MB` still true) with no version
literal to rot. (Writing that placeholder's name literally in this entry is
the trap ww12's finished-dist sweep exists to catch, and it is dodged here
the way it was dodged at ww13.) /changelog renders the new entry, THE BYTE
ARRIVES (is36).

The two lupin literals /play/ carries by design (`v0.1.22` and `v0.1.23`,
about when the observation record started carrying a trapping program's
output) were re-read by hand at this bump and both hold. They are audited
against the *wolf* pin, which did not move, so the allowlist did not force
that reading; wolf-web#8 is still the hole it was, and this is the second
wave in a row it had to be covered manually.

One upstream finding rides along without touching this site: byte has the
type but not the domain (wolf-interp#62). `byte` resolves and the casts
hold, but `0..=255` is not enforced where an un-cast `int` flows into a byte
slot: `List[byte].push(256)` stores 256 here where the compilers refuse
`E0401`. All thirty-three menu programs were checked against it and none is
exposed: the ladder truncates by clause (`256 as byte`), and the only other
sample that touches the type is `projects/rpn.lu`, which reads bytes out of
`tok.bytes()` with `b as int` and pushes nothing back in. is37 fixes it.

## ww13 — 2026-09-03

The byte on the page. The pins move to wolf v0.2.4 and lupin 0.1.24, and the
release's headline is a breaking change one line wide, so it is on /install/
rather than only in the changelog. `str.bytes()` yields `byte` now, an 8-bit
unsigned octet, and the first thing anyone does with one is compare it to a
number, which is `E0401`. The page quotes the compiler finishing that
sentence: "`byte` adopts no literal and takes no `int` implicitly
([type.byte]): widen the byte — `b as int` — or narrow this side with `as
byte`". The Windows job builds that program on a Windows runner, reads the
note back, and then builds the line the note names and runs it: `w is 119`,
exit 0. Exit 1 for the refusal, measured on the runner, and the page draws
the distinction a learner needs: an ordinary program that does not compile,
where this host's own refusals answer exit 2.

Unix-domain sockets are the third named refusal on Windows, new at this
release. `net_listen_unix` compiles here and answers the `unsupported` row
with a name instead of a bare `io` failure, which is the difference between a
program that can branch on the host and one that cannot; the limits section's
opener owns its count and now says three. Both halves are measured: the
corpus's own witness runs on the runner for its pinned stdout and for the exit
3 it would take if a bind ever failed with a path row, and a second probe
beside it says which branch of that construction this host took, because a
witness that passes vacuously proves nothing about a sentence.

The playground runs a byte sample that does not run.
`corpus/typecheck/byte_casts.lu` (the cast ladder, where 256 truncates to 0
and -1 to 255 and the widen is zero-extension) is the thirty-third program on
the menu, and lupin 0.1.24 answers `fail(E0301)` on it at resolve, because
`as byte` names no type that release knows. It is on the menu anyway, marked,
with the reason on the page: the interpreter tagged its byte work at is35 and
the type's producers landed after the wolf release 0.1.24 was built against.
The page promises nothing about when that changes. A gate holds it rather
than a memory: `scripts/check-samples.mjs` feeds every menu program to the
wasm module the build published and refuses in both directions, so an unnoted
entry must answer `exit` or `trap` and a noted one must not. The day the
interpreter starts running it, CI goes red and the note comes off because it
has to. The whole run set was re-measured through that module at the new pin:
282 `phase: run` corpus programs, 192 `exit`, 31 `trap`, 49 `unsupported`,
and 10 `fail`, a class that was empty a week ago and one holding the nine
byte programs plus `grammar/bom_at_start.lu`.

The pin lag is still one release, and the CI step stayed as it was. lupin
0.1.24 was released against pin `3befc3e` (wolf v0.2.3) while this site
advertises v0.2.4, so the gap the step holds at one is one, and the sentence
/install/ and /play/ both write is unchanged. It would have gone to zero at a
lupin 0.1.25; there is no 0.1.25.

Three sentences had rotted the way ww12's Windows headline did, each
phrased relative to "the release before this one" and each false the moment
the pin moved: native compilation arriving "one release ago", lupin's
second-opinion distinction being "new at" this version, and the missing arm
archive. All three name the release they mean now, as five new version
literals, listed and audited in the allowlist.

And the measured sizes stamp themselves. The spec and docs pages print how
big each document is so a reader knows what a link costs, and those numbers
were written by hand: four had drifted (spec/01 52 to 53 KiB, spec/02 47 to
48, spec/10 13 to 17 because `byte` is declared in it, spec/11 14 to 16
because the first socket clause is), plus the diagnostics catalogue at 151 to
154. The ww12 pass had re-recorded three of the same class by hand a week
earlier. They work the way version claims have worked since ww07 now: a page
names the document it is sizing in a placeholder and the build fills the
number in from the pinned checkout, refusing when the placeholder names a
file the pin does not carry. (Writing that token literally in this entry is
what the finished dist sweep added at ww12 exists to catch, and it caught
it.)
Fifteen numbers can no longer be wrong. The code counts are still by hand and
were re-read at this pin: 136 diagnostics, 33 warnings, both unmoved.

Twenty claims re-recorded in all. /changelog renders v0.2.4, learner-first
paragraph at the top: THE BYTE SHIPS. One finding went upstream the same day:
lupin resolves a cast target by scope lookup, so `as byte` and a misspelled
`as itn` produce byte-identical reports, and the note tells a reader to hunt
for a typo that is not there (wolf-interp#60). The lupin-shaped hole in this
repo's own tripwire (wolf-web#8) had to be dodged again, by spelling a
historical lupin version `v0.1.23` where a bare `0.1.23` would have been
invisible to the checker.

## ww12 — 2026-09-02

The flip. The ww11 pass left one line to change and a runner that had been
recording the "before" every week: three corpus programs (the task layer,
channel transfer, signal reception) run on a Windows box against the published
archive and tabulated, asserted nothing, and waited for a tag. v0.2.3 is the
tag. Against `wolf-0.2.3-x86_64-pc-windows-msvc.tar.gz`, fetched by the URL
the page prints, all three serve: `corpus/conc/spawn_fanout_loop.lu` exits 0
printing `204`, `corpus/conc/message_passing.lu` exits 0 printing nothing,
`corpus/os/signal_loopback.lu` exits 0 printing `reload`, each byte-for-byte
the `stdout=` its own corpus header pins. The job asserts them now.

So /install/'s limits paragraph retires. The twenty-one by-name refusals
are gone, the `windows-native serves no `spawn`/scopes` transcript comes off
the page, and two named refusals take their place: `wolf build --release`,
exit 2, quoted as the runner printed it (the page had been truncating the
sentence's parenthetical), and external `reload`/`upgrade` delivery, which has
no Windows analog. The second needed care: the page must not say `os.signal`
is unserved when the loopback witness prints `reload` on that host; what a
learner cannot do is send one from another process. The no-toolchain refusal
was re-captured at the tag and has not moved a byte. Three claims in the job
inverted with the prose: `wolf build fanout.lu` now asserts exit 0, an
ordinary `fanout.exe`, and that no refusal names `windows-native` at all.

The linux-aarch64 hedge retires too. The ww10 pass wrote "an archive per host
that passes their own unpack-and-run smoke" because v0.2.2 shipped three
archives and threw the arm one away (wolf-lang#213, filed at ww10, fixed
here). Four archives at this tag, and a measurement replaces the qualifier:
the Windows job HEADs all four release URLs on every push and requires 200 and
a toolchain-sized body, 68.2 MB linux x86-64, 57.2 MB linux aarch64, 13.4 MB
macOS, 11.5 MB windows. /install/ gained the paragraph that
says what the arm archive serves, which is the checked tier, because that host
still has no native backend.

The two pins are one release apart, and the site says so. lupin 0.1.23 was
released against pin `8cda3aa` (wolf v0.2.2) while the compiler this site
advertises is v0.2.3. `wolf --version` prints both on the runner: `wolf 0.2.3
(wolfgang, pin 3befc3e)`, then `paired with lupin 0.1.23 (reference
interpreter), pin 8cda3aa`. /install/ records it beside the line that explains
that output, the playground records it where the interpreter actually runs
(the explanation for a program answering differently in the tab than under a
freshly installed wolf), and a CI step holds the gap at one release in both
directions: when lupin catches up, the sentence goes red instead of
rotting.

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
lanes print, so the witness joins the sample menu as *a trap runs no
defers*, and a reader can watch the two implementations agree. The reason
nobody could see that disagreement is the second change: through v0.1.22 the
observation record reported `stdout_inline: null` on every trapping program,
so the two machines were record-identical whatever they printed, and the
playground's record note now says so beside the button that shows one. The
third is a kindness a learner meets first: a missing comma used to answer
``expected `}`, found identifier `y` `` and stop, and now finishes the
sentence, "the members of a struct literal are separated — add the comma",
with a second line, `the comma goes here at 18:25`, pointing at the
zero-width spot where it belongs. The primary span did not move a byte. The
whole run set was re-measured against the new module: 270 conformance
programs, every one in the verdict class it answered in at 0.1.22.

The compiler pin does not move. wolf's trunk already serves tasks, channels
and signals on Windows, which will make /install/'s limits paragraph false the
moment it is tagged, but there is no tag, no archive, and nothing this site's
CI could fetch to check a sentence about it, so the page keeps v0.2.2's
measured truth and promises nothing about the next release. What the Windows
job gained instead is the measurement, taken early: three parity probes (the
task layer, channel transfer, signal reception) run on the runner every week
and are recorded, not asserted. At v0.2.2 all three
refuse with exit 1, each naming the symbol that would not link
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
sentence /install/ was built to say last week is retracted: the compiler
builds and runs native Windows programs now. `wolf run hello.lu` prints
`hello, wolf` on a Windows box, `wolf build` leaves an ordinary `hello.exe`
you can send to someone who has no wolf at all, and the page leads with that
instead of with a refusal. One thing has to be installed beside it, Visual
Studio Build Tools with "Desktop development with C++", and instead of
describing what a learner without it sees, the CI job takes the Windows SDK
away from its own runner for the length of one command and quotes the
transcript: exit 2, and a refusal that names the three import libraries and
the workload that carries them. The same job asserts the other half of that
story, which is that no Developer Command Prompt is needed: wolf finds the
toolchain itself from a plain shell with `LIB` unset. What still refuses is
one region of the language rather than a tier: concurrency and the operating
system's edges, twenty-one corpus programs. The page quotes that refusal too,
with the compiler's own per-host ledger linked at the tag.
`wolf conform-run --checked`, which was the only way to run a program on
Windows through v0.2.1, is demoted to the specialist's tool it always was,
and the paragraph teaching learners to type `.\hello.lu` is gone because
wolf-lang#206 closed at this tag. The reference interpreter has binaries for
the first time, so the section that pointed at nothing now links
`lupin.exe`, one file, downloaded and smoked on the runner beside the
compiler. The playground runs 0.1.22, whose headline is a region with a
budget, and both cap witnesses are in its menu: the boundary that holds and
the breach that traps with the ledger arithmetic in the message. Three
findings went upstream the same morning: v0.2.2 shipped no linux-aarch64
archive because the new dist smoke gates upload on a native tier that host
does not serve (wolf-lang#213), its release page carries no notes at all
(wolf-lang#214), and lupin's comma refusals carry no "add the comma" note
where the compiler's do (wolf-interp#56).

## ww09a — 2026-09-02 — the editor gets its width back

- The playground's two-column split moved from 60rem to 96rem and became
  3:2 in the editor's favor: below that, one column, with the editor at the
  page's full width and output beneath. At the old breakpoint the editor got
  ~30rem (about 50 columns), `wrap=off` clipped the rest, and the empty
  output pane looked like reserved editor space (the human's report).
  CSS only; CSP, editor code, and markup untouched.

## ww09 — 2026-09-01

The Windows welcome. The site gains /install/, and its Windows section was
written from the measurement: a windows-latest job in this repo's CI
downloads the published archive by the same URL the page prints, unpacks it
with the same `tar`, and asserts every claim the page makes (word for word,
exit code for exit code) on every push and once a week besides. What that job
found is what the page now says. The compiler runs on Windows up to code
generation: `wolf --version`, `wolf --explain`,
`wolf fmt`, `wolf test`, and `wolf conform-run <file> --checked`, which
executes a first program on the compiler's checked machine and prints its
output in the record. `wolf build` and `wolf run` name the host in their
refusal and exit 2, and the page quotes that refusal whole instead of
paraphrasing it; native Windows builds are in progress and the page names no
date. Two
Windows-shaped facts a learner would otherwise hit blind are on the page
because the runner hit them: a file saved by Notepad is not canonically
formatted until `wolf fmt` rewrites it, and `conform-run` needs `.\hello.lu`
where every other verb takes a bare name (wolf-lang#206). The reference
interpreter is published as a binary for no platform at all, so the page says
so and points at the playground rather than linking a Linux tarball
(wolf-interp#54). The playground's own Windows caveat is now printed beside
its key bindings (Ctrl+Alt+arrows is screen rotation on some laptops), and
the editor's suites run on a Windows runner, where node reports Win32 and
every binding is exercised in its Ctrl spelling.

## ww08 — 2026-09-01

The site catches the wave. The pins move to wolf v0.2.1, lupin 0.1.20 and
the book at bs22, four book sprints and two releases in one turn of the
crank. The playground now runs an interpreter whose `match` arms take a
struct apart by field name, and whose `defer` in a loop body fires at the
end of every turn rather than when the function returns, which is the
transcript the book's §4.3 now teaches. The book on the site gains the
45-exercise K&R ladder, chapter 25's first printed section on `wolf publish`, the
corrected `defer` teaching and three pattern exercises: 327 exercises in
the corpus, 278 printed on the pages, each with a solution. /changelog
carries the book's own entries for the first time (bs19 through bs22)
beside wolf 0.2.1 and lupin 0.1.20. Three prose claims the new pins moved
were re-recorded, and the spec page's `grammar/1` posture is now stamped
from the pin at build time instead of naming a version by hand.

## ww07 — 2026-08-31

The prose catches up. Every version claim on the site was re-recorded
against the pins it already served: eleven stale claims, from "this is
version 0.1.0" under a v0.2.0 toolchain to a spec page missing four
normative documents. A tripwire now keeps the class at zero:
current-version claims are stamped into the pages at build time from the
pinned checkouts, and every literal version mention must be counted and
re-audited on each pin bump or the build refuses. The site also grew
/changelog: each public project's CHANGELOG.md rendered from the pinned
checkout it was built from, with a repo that has none yet getting a page
that says so instead of a broken link.

## ww06 — 2026-08-30

The site catches up. Pins move to wolf v0.2.0, lupin v0.1.18 and the
post-bs19 book, so the playground runs six releases' worth of
interpreter (+10.7% wasm) and diagnostics point at line:col instead of
byte offsets. The editor grows manners: auto-indent, wolf-aware bracket
pairing (interpolation braces pair inside strings), goal columns, and
multi-cursor editing with one-step undo. A CSP gate proves no script
source was added to get them.

## ww05 — 2026-08-26

The PDF on the page. The reading page offers the typst-set print edition
for download, rendered from the same pinned book source as the web
pages, with its measured size printed beside the link, and the line
removed entirely when a build has no PDF, so the page never advertises a
file the dist does not carry. Trunk work soon after fixed the page the
fix shipped on: a 0600 file had been 403ing live, and the build now
refuses any dist file nginx cannot read.

## ww00-era — 2026-08-13 to 2026-08-22

The site exists. A landing page, the playground (lupin compiled to
WebAssembly, running conformance-corpus samples entirely in the tab),
the spec and diagnostic catalogues copied from a pinned compiler
checkout, and the book rendered from its own pinned repo. Everything
served is generated from submodule pins, so no page can claim a version
of wolf that does not exist. CI builds on every push, a link checker walks
the dist, deploys go to lupp.us over a restricted key, and a build
missing a piece refuses to ship unless a waiver names it.
