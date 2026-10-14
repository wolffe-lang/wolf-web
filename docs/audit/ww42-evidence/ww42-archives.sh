# ww42: the 0.2.29 and 0.1.52 release archives by digest, each read twice (kasumi), and the archive's std/ held to
# the manifest wolf-book 0a5fecc's CI names (book.yml:193, 229202f5…), computed by that step's own recipe.
# Each archive is downloaded twice into separate files; both must hash to the digest GitHub publishes for the asset.
L=~/lanes/ww42; A=$L/archives; mkdir -p $A; cd $A || exit 1
echo "archives run $(date -u +%FT%TZ) on $(hostname)"
fail=0
get() { # repo tag asset
  want=$(gh api repos/wolffe-lang/$1/releases/tags/$2 -q ".assets[]|select(.name==\"$3\")|.digest" | sed 's/^sha256://')
  test -n "$want" || { echo "NO DIGEST for $3"; fail=1; return; }
  for n in 1 2; do curl -sfL -o $3.$n https://github.com/wolffe-lang/$1/releases/download/$2/$3 || { echo "DOWNLOAD $n FAILED $3"; fail=1; return; }; done
  a=$(sha256sum $3.1 | cut -c1-64); b=$(sha256sum $3.2 | cut -c1-64)
  if [ "$a" = "$want" ] && [ "$b" = "$want" ]; then echo "ok   $3 published $want read1 $a read2 $b ($(stat -c %s $3.1) B)"; else echo "FAIL $3 published $want read1 $a read2 $b"; fail=1; fi
}
for t in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-unknown-linux-gnu; do get wolf-lang v0.2.29 wolf-0.2.29-$t.tar.gz; done
for a in lupin-0.1.52-aarch64-apple-darwin.tar.gz lupin-0.1.52-aarch64-unknown-linux-gnu.tar.gz lupin-0.1.52-x86_64-pc-windows-msvc.zip lupin-0.1.52-x86_64-unknown-linux-gnu.tar.gz lupin.exe; do get wolf-interp v0.1.52 $a; done
sha() { sha256sum "$@"; }
for t in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-unknown-linux-gnu; do
  d=wolf-0.2.29-$t; rm -rf x-$t; mkdir x-$t && tar -xzf $d.tar.gz.1 -C x-$t || { echo "UNPACK FAILED $t"; fail=1; continue; }
  test -d x-$t/$d/std || { echo "FAIL $t: no std/ in the archive folder"; fail=1; continue; }
  got=$(cd x-$t/$d && find std -type f | LC_ALL=C sort | while IFS= read -r f; do printf '%s  %s\n' "$(sha "$f" | cut -c1-64)" "$f"; done | sha | cut -c1-64)
  want=229202f5b6477b3dfd4635996e31342ed9143c7a377ae6c3bdeb2faf5a28a830
  n=$(cd x-$t/$d && find std -type f | wc -l); rev=$(cat x-$t/$d/std/STD-REV)
  [ "$got" = "$want" ] && v=ok || { v=FAIL; fail=1; }
  echo "$v   $d: folder $(ls x-$t/$d | tr '\n' ' '); std/ $n files, manifest $got (book.yml wants $want), STD-REV $rev"
done
echo "linux x86-64 wolf --version:"; x-x86_64-unknown-linux-gnu/wolf-0.2.29-x86_64-unknown-linux-gnu/wolf --version
mkdir -p xl && tar -xzf lupin-0.1.52-x86_64-unknown-linux-gnu.tar.gz.1 -C xl && find xl -name lupin -type f -exec {} --version \;
echo "std.signal in the archive: $(grep -cE '^pub fn ' x-x86_64-unknown-linux-gnu/wolf-0.2.29-x86_64-unknown-linux-gnu/std/signal/*.lu | tr '\n' ' ')"
grep -lE 'os_pid|os_ppid|os_signal_send|os_signal_number|os_signal_ignored' -r x-x86_64-unknown-linux-gnu/wolf-0.2.29-x86_64-unknown-linux-gnu/std; echo "(files under the archive's std/ naming any of the five new builtins: listed above, none if blank)"
rm -rf $A/x-* $A/xl $A/*.1 $A/*.2
echo "ARCHIVES-FAIL=$fail"; echo ARCHIVES-DONE
