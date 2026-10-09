# ww40: the published lupin 0.1.49 linux archive (kasumi): digest against GitHub's and wolf 0.2.26's PAIRING note,
# then the rows the pages name, at a terminal.
L=~/lanes/ww40; mkdir -p $L/native && cd $L/native || exit 1
U=https://github.com/wolffe-lang/wolf-interp/releases/download/v0.1.49/lupin-0.1.49-x86_64-unknown-linux-gnu.tar.gz
curl -sfLO $U || exit 1
sha256sum lupin-0.1.49-x86_64-unknown-linux-gnu.tar.gz
rm -rf x && mkdir x && tar -xzf lupin-0.1.49-x86_64-unknown-linux-gnu.tar.gz -C x || exit 1
B=$(find x -type f -name lupin | head -1); echo "binary $B"; sha256sum $B; $B --version
C=$L/web/upstream/wolf-lang
git -C $C checkout -q 89dc139443da38078df6093568da87bc6d0ee6f9 || exit 1
for f in grammar/cfg_target_arch.lu conc/atomic_fence.lu conc/atomic_orders.lu conc/atomic_widths.lu conc/atomic_counter.lu memory/volatile_widths.lu memory/packed_field_raw_read.lu memory/raw_repr_c_layout.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu membrane/extern_libc.lu typecheck/fn_never_extern.lu os/chdir_relative.lu os/pipe_round_trip.lu fs/std_write_bytes.lu; do
  echo "== $f"; (cd $C/corpus && timeout 60 $L/native/$B run $f; echo "exit=$?") 2>&1 | tail -10
done
git -C $C checkout -q 6710f9e0cbc3a7264349093751ce7a46a407e473 || exit 1
echo NATIVE-DONE
