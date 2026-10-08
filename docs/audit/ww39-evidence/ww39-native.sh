# ww39: the published lupin 0.1.48 linux archive (kasumi): digest against GitHub's and wolf 0.2.25's PAIRING note,
# then the rows the pages name, at a terminal.
L=~/lanes/ww39; mkdir -p $L/native && cd $L/native || exit 1
U=https://github.com/wolffe-lang/wolf-interp/releases/download/v0.1.48/lupin-0.1.48-x86_64-unknown-linux-gnu.tar.gz
curl -sfLO $U || exit 1
sha256sum lupin-0.1.48-x86_64-unknown-linux-gnu.tar.gz
rm -rf x && mkdir x && tar -xzf lupin-0.1.48-x86_64-unknown-linux-gnu.tar.gz -C x || exit 1
B=$(find x -type f -name lupin | head -1); echo "binary $B"; sha256sum $B; $B --version
C=$L/web/upstream/wolf-lang
git -C $C checkout -q 6710f9e0cbc3a7264349093751ce7a46a407e473 || exit 1
for f in grammar/cfg_target_arch.lu comptime/layout_query_repr_c.lu memory/packed_fields_at_offset_of.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu memory/packed_field_raw_read.lu conc/atomic_fence.lu conc/atomic_widths.lu memory/volatile_widths.lu memory/static_var_call_writes.lu; do
  echo "== $f"; (cd $C/corpus && timeout 60 $L/native/$B run $f; echo "exit=$?") 2>&1 | tail -4
done
git -C $C checkout -q 8edac3eeb48632b32f02ef41ea87d484d1423492 || exit 1
echo NATIVE-DONE
