# ww46: the 0.2.34 and 0.1.55 release archives by digest, each read twice (kasumi), and the archive's std/ held to
# the manifest wolf-book f1fd824's CI names (book.yml:193, 4382865a…), computed by that step's own recipe. Then the
# book CI's staging step mirrored: wolf-std at wolf-lang v0.2.34's STD-PIN, cloned with autocrlf off, std/ copied into
# a target dir with the two licences and STD-REV, the same manifest recipe, which must equal both the archive's and
# book.yml's. Each archive is downloaded twice into separate files; both must hash to the digest GitHub publishes.
# The linux x86-64 pair is kept unpacked under ~/lanes/ww46/pair/ for the terminal probes (std/ beside wolf, as the
# archive places it).
L=~/lanes/ww46; A=$L/archives; mkdir -p "$A"; cd "$A" || exit 1
echo "archives run $(date -u +%FT%TZ) on $(hostname)"
fail=0
get() { # repo tag asset
  want=$(gh api repos/wolffe-lang/$1/releases/tags/$2 -q ".assets[]|select(.name==\"$3\")|.digest" | sed 's/^sha256://')
  test -n "$want" || { echo "NO DIGEST for $3"; fail=1; return; }
  for n in 1 2; do curl -sfL -o $3.$n https://github.com/wolffe-lang/$1/releases/download/$2/$3 || { echo "DOWNLOAD $n FAILED $3"; fail=1; return; }; done
  a=$(sha256sum $3.1 | cut -c1-64); b=$(sha256sum $3.2 | cut -c1-64)
  if [ "$a" = "$want" ] && [ "$b" = "$want" ]; then echo "ok   $3 published $want read1 $a read2 $b ($(stat -c %s $3.1) B)"; else echo "FAIL $3 published $want read1 $a read2 $b"; fail=1; fi
}
echo "release ids: wolf-lang v0.2.34 $(gh api repos/wolffe-lang/wolf-lang/releases/tags/v0.2.34 -q .id), wolf-interp v0.1.55 $(gh api repos/wolffe-lang/wolf-interp/releases/tags/v0.1.55 -q .id)"
for t in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-unknown-linux-gnu; do get wolf-lang v0.2.34 wolf-0.2.34-$t.tar.gz; done
for a in lupin-0.1.55-aarch64-apple-darwin.tar.gz lupin-0.1.55-aarch64-unknown-linux-gnu.tar.gz lupin-0.1.55-x86_64-pc-windows-msvc.zip lupin-0.1.55-x86_64-unknown-linux-gnu.tar.gz lupin.exe; do get wolf-interp v0.1.55 $a; done
sha() { sha256sum "$@"; }
manifest() { (cd "$1" && find std -type f | LC_ALL=C sort | while IFS= read -r f; do printf '%s  %s\n' "$(sha "$f" | cut -c1-64)" "$f"; done | sha | cut -c1-64); }
want=5d6253b63c97c050e3bf068cfb15c8515453b7ec5b98cd62a91a955bd2a9fc9a
for t in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-unknown-linux-gnu; do
  d=wolf-0.2.34-$t; rm -rf "${A:?}/x-$t"; mkdir x-$t && tar -xzf $d.tar.gz.1 -C x-$t || { echo "UNPACK FAILED $t"; fail=1; continue; }
  test -d x-$t/$d/std || { echo "FAIL $t: no std/ in the archive folder"; fail=1; continue; }
  got=$(manifest x-$t/$d)
  n=$(cd x-$t/$d && find std -type f | wc -l); nl=$(cd x-$t/$d && find std -type f -name '*.lu' | wc -l); rev=$(cat x-$t/$d/std/STD-REV)
  [ "$got" = "$want" ] && v=ok || { v=FAIL; fail=1; }
  echo "$v   $d: folder $(ls x-$t/$d | tr '\n' ' '); std/ $n files ($nl .lu), manifest $got (book.yml wants $want), STD-REV $rev"
done
echo "=== the book CI's staging step, mirrored (book.yml:173-195 at f1fd824)"
pin=$(git -C $L/web/upstream/wolf-lang show v0.2.34:crates/wolf_driver/STD-PIN | awk -F' = ' '/^wolf-std-commit = /{print $2}')
echo "STD-PIN at v0.2.34: wolf-std-commit = $pin"
rm -rf "${A:?}/stage" && mkdir -p "$A/stage/target/release" && cd "$A/stage" || exit 1
git -c core.autocrlf=false clone --quiet https://github.com/wolffe-lang/wolf-std wolf-std || { echo "CLONE FAILED"; fail=1; }
git -C wolf-std -c core.autocrlf=false checkout --quiet "$pin" || { echo "CHECKOUT FAILED"; fail=1; }
echo "wolf-std at $(git -C wolf-std rev-parse HEAD)"
dest=target/release/std
cp -R wolf-std/std "$dest" && cp wolf-std/LICENSE wolf-std/LICENSE-EXCEPTION "$dest/" && git -C wolf-std rev-parse HEAD > "$dest/STD-REV"
got=$(manifest target/release); n=$(cd target/release && find std -type f | wc -l); nl=$(cd target/release && find std -type f -name '*.lu' | wc -l)
[ "$got" = "$want" ] && v=ok || { v=FAIL; fail=1; }
echo "$v   staged std/: $n files ($nl .lu), manifest $got (book.yml wants $want)"
echo "staged vs the linux x86-64 archive's std/: $(diff -r target/release/std $A/x-x86_64-unknown-linux-gnu/wolf-0.2.34-x86_64-unknown-linux-gnu/std > /dev/null && echo IDENTICAL || echo DIFFER)"
cd "$A" || exit 1
echo "STD-REV as the book stages it: $(cat stage/target/release/std/STD-REV); the archive's: $(cat x-x86_64-unknown-linux-gnu/wolf-0.2.34-x86_64-unknown-linux-gnu/std/STD-REV)"
echo "linux x86-64 wolf --version:"; x-x86_64-unknown-linux-gnu/wolf-0.2.34-x86_64-unknown-linux-gnu/wolf --version
mkdir -p xl && tar -xzf lupin-0.1.55-x86_64-unknown-linux-gnu.tar.gz.1 -C xl && find xl -name lupin -type f -exec {} --version \;
S=x-x86_64-unknown-linux-gnu/wolf-0.2.34-x86_64-unknown-linux-gnu/std
echo "std.process and std.signal pub fns in the archive: $(grep -cE '^pub fn ' $S/process/*.lu $S/signal/*.lu | tr '\n' ' ')"
grep -rnE 'os_signal_ignore_one|os_signal_default_one|os_exit_signal|os_wait_status_core|os_wait_poll_core' $S | head; echo "(std lines naming any of the five 0.2.34 builtins: listed above, none if blank)"
grep -rnE 'fn (poll|send_group|send_all|lead_group|join_group|group_of|own_group|status_from|realtime|text|host|last)\b' $S | cut -c1-160 | head -20; echo "(ruling #85's wrappers in the archive's std: listed above)"
rm -rf "${L:?}/pair" && mkdir -p "$L/pair" && tar -xzf wolf-0.2.34-x86_64-unknown-linux-gnu.tar.gz.1 -C "$L/pair" && tar -xzf lupin-0.1.55-x86_64-unknown-linux-gnu.tar.gz.1 -C "$L/pair" && echo "pair kept: $(ls $L/pair | tr '\n' ' ')"
rm -rf "${A:?}"/x-* "${A:?}/xl" "${A:?}/stage" "${A:?}"/*.1 "${A:?}"/*.2
echo "ARCHIVES-FAIL=$fail"; echo ARCHIVES-DONE
