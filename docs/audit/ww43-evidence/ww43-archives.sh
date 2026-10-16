# ww43: the 0.2.30 and 0.1.53 release archives by digest, each read twice (kasumi), and the archive's std/ held to
# the manifest wolf-book 95d68ad's CI names (book.yml:193, ab2576df…), computed by that step's own recipe.
# Each archive is downloaded twice into separate files; both must hash to the digest GitHub publishes for the asset.
L=~/lanes/ww43; A=$L/archives; mkdir -p $A; cd $A || exit 1
echo "archives run $(date -u +%FT%TZ) on $(hostname)"
fail=0
get() { # repo tag asset
  want=$(gh api repos/wolffe-lang/$1/releases/tags/$2 -q ".assets[]|select(.name==\"$3\")|.digest" | sed 's/^sha256://')
  test -n "$want" || { echo "NO DIGEST for $3"; fail=1; return; }
  for n in 1 2; do curl -sfL -o $3.$n https://github.com/wolffe-lang/$1/releases/download/$2/$3 || { echo "DOWNLOAD $n FAILED $3"; fail=1; return; }; done
  a=$(sha256sum $3.1 | cut -c1-64); b=$(sha256sum $3.2 | cut -c1-64)
  if [ "$a" = "$want" ] && [ "$b" = "$want" ]; then echo "ok   $3 published $want read1 $a read2 $b ($(stat -c %s $3.1) B)"; else echo "FAIL $3 published $want read1 $a read2 $b"; fail=1; fi
}
for t in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-unknown-linux-gnu; do get wolf-lang v0.2.30 wolf-0.2.30-$t.tar.gz; done
for a in lupin-0.1.53-aarch64-apple-darwin.tar.gz lupin-0.1.53-aarch64-unknown-linux-gnu.tar.gz lupin-0.1.53-x86_64-pc-windows-msvc.zip lupin-0.1.53-x86_64-unknown-linux-gnu.tar.gz lupin.exe; do get wolf-interp v0.1.53 $a; done
sha() { sha256sum "$@"; }
for t in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-unknown-linux-gnu; do
  d=wolf-0.2.30-$t; rm -rf x-$t; mkdir x-$t && tar -xzf $d.tar.gz.1 -C x-$t || { echo "UNPACK FAILED $t"; fail=1; continue; }
  test -d x-$t/$d/std || { echo "FAIL $t: no std/ in the archive folder"; fail=1; continue; }
  got=$(cd x-$t/$d && find std -type f | LC_ALL=C sort | while IFS= read -r f; do printf '%s  %s\n' "$(sha "$f" | cut -c1-64)" "$f"; done | sha | cut -c1-64)
  want=ab2576df6580d2935eee453cec5b7383d26e3242fe4a1da40132f5582ee8bbfa
  n=$(cd x-$t/$d && find std -type f | wc -l); rev=$(cat x-$t/$d/std/STD-REV)
  [ "$got" = "$want" ] && v=ok || { v=FAIL; fail=1; }
  echo "$v   $d: folder $(ls x-$t/$d | tr '\n' ' '); std/ $n files, manifest $got (book.yml wants $want), STD-REV $rev"
done
echo "linux x86-64 wolf --version:"; x-x86_64-unknown-linux-gnu/wolf-0.2.30-x86_64-unknown-linux-gnu/wolf --version
mkdir -p xl && tar -xzf lupin-0.1.53-x86_64-unknown-linux-gnu.tar.gz.1 -C xl && find xl -name lupin -type f -exec {} --version \;
echo "std.signal and std.term in the archive: $(grep -cE '^pub fn ' x-x86_64-unknown-linux-gnu/wolf-0.2.30-x86_64-unknown-linux-gnu/std/term/*.lu | tr '\n' ' ')"; echo "std.signal in the archive: $(grep -cE '^pub fn ' x-x86_64-unknown-linux-gnu/wolf-0.2.30-x86_64-unknown-linux-gnu/std/signal/*.lu | tr '\n' ' ')"
grep -lE 'os_term_size|os_term_chars|os_signal_wait_fd|os_uid|os_euid|os_gid|os_egid|os_groups|os_set_ids|fs_set_owner|fs_set_owner_fd' -r x-x86_64-unknown-linux-gnu/wolf-0.2.30-x86_64-unknown-linux-gnu/std; echo "(files under the archive's std/ naming any of the eleven new builtins: listed above, none if blank)"
rm -rf $A/x-* $A/xl $A/*.1 $A/*.2
echo "ARCHIVES-FAIL=$fail"; echo ARCHIVES-DONE
