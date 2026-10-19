# ww44: the 0.2.32 and 0.1.54 release archives by digest, each read twice (kasumi), and the archive's std/ held to
# the manifest wolf-book e9862f6's CI names (book.yml:193, 1f7389b7…), computed by that step's own recipe.
# Each archive is downloaded twice into separate files; both must hash to the digest GitHub publishes for the asset.
L=~/lanes/ww44; A=$L/archives; mkdir -p $A; cd $A || exit 1
echo "archives run $(date -u +%FT%TZ) on $(hostname)"
fail=0
get() { # repo tag asset
  want=$(gh api repos/wolffe-lang/$1/releases/tags/$2 -q ".assets[]|select(.name==\"$3\")|.digest" | sed 's/^sha256://')
  test -n "$want" || { echo "NO DIGEST for $3"; fail=1; return; }
  for n in 1 2; do curl -sfL -o $3.$n https://github.com/wolffe-lang/$1/releases/download/$2/$3 || { echo "DOWNLOAD $n FAILED $3"; fail=1; return; }; done
  a=$(sha256sum $3.1 | cut -c1-64); b=$(sha256sum $3.2 | cut -c1-64)
  if [ "$a" = "$want" ] && [ "$b" = "$want" ]; then echo "ok   $3 published $want read1 $a read2 $b ($(stat -c %s $3.1) B)"; else echo "FAIL $3 published $want read1 $a read2 $b"; fail=1; fi
}
for t in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-unknown-linux-gnu; do get wolf-lang v0.2.32 wolf-0.2.32-$t.tar.gz; done
for a in lupin-0.1.54-aarch64-apple-darwin.tar.gz lupin-0.1.54-aarch64-unknown-linux-gnu.tar.gz lupin-0.1.54-x86_64-pc-windows-msvc.zip lupin-0.1.54-x86_64-unknown-linux-gnu.tar.gz lupin.exe; do get wolf-interp v0.1.54 $a; done
sha() { sha256sum "$@"; }
for t in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-unknown-linux-gnu; do
  d=wolf-0.2.32-$t; rm -rf x-$t; mkdir x-$t && tar -xzf $d.tar.gz.1 -C x-$t || { echo "UNPACK FAILED $t"; fail=1; continue; }
  test -d x-$t/$d/std || { echo "FAIL $t: no std/ in the archive folder"; fail=1; continue; }
  got=$(cd x-$t/$d && find std -type f | LC_ALL=C sort | while IFS= read -r f; do printf '%s  %s\n' "$(sha "$f" | cut -c1-64)" "$f"; done | sha | cut -c1-64)
  want=1f7389b7a666f9915df3e8ba68881437cf2b81ebc81184c043e5155dd1bba4a8
  n=$(cd x-$t/$d && find std -type f | wc -l); rev=$(cat x-$t/$d/std/STD-REV)
  [ "$got" = "$want" ] && v=ok || { v=FAIL; fail=1; }
  echo "$v   $d: folder $(ls x-$t/$d | tr '\n' ' '); std/ $n files, manifest $got (book.yml wants $want), STD-REV $rev"
done
echo "linux x86-64 wolf --version:"; x-x86_64-unknown-linux-gnu/wolf-0.2.32-x86_64-unknown-linux-gnu/wolf --version
mkdir -p xl && tar -xzf lupin-0.1.54-x86_64-unknown-linux-gnu.tar.gz.1 -C xl && find xl -name lupin -type f -exec {} --version \;
echo "std.process and std.signal in the archive: $(grep -cE '^pub fn ' x-x86_64-unknown-linux-gnu/wolf-0.2.32-x86_64-unknown-linux-gnu/std/process/*.lu | tr '\n' ' ')"; grep -rlE 'fn (poll|send_group|send_all)\b' x-x86_64-unknown-linux-gnu/wolf-0.2.32-x86_64-unknown-linux-gnu/std; echo "(std files declaring poll, send_group or send_all: listed above, none if blank)"
grep -lE 'os_signal_send_group|os_signal_send_all|os_set_pgid|os_signal_last|os_signal_realtime|os_signal_text|os_wait_poll' -r x-x86_64-unknown-linux-gnu/wolf-0.2.32-x86_64-unknown-linux-gnu/std; echo "(files under the archive's std/ naming any of the seven 0.2.31 builtins: listed above, none if blank)"
rm -rf $A/x-* $A/xl $A/*.1 $A/*.2
echo "ARCHIVES-FAIL=$fail"; echo ARCHIVES-DONE
