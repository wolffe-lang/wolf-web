# ww42 (adapted from ww40-native.sh): the published lupin 0.1.52 linux archive (kasumi), digest against GitHub's,
# then at a terminal the rows the pages name, the one arrival, the moved row, and the five new builtins' probes.
L=~/lanes/ww42; mkdir -p $L/native && cd $L/native || exit 1
U=https://github.com/wolffe-lang/wolf-interp/releases/download/v0.1.52/lupin-0.1.52-x86_64-unknown-linux-gnu.tar.gz
curl -sfLO $U || exit 1
echo "published $(gh api repos/wolffe-lang/wolf-interp/releases/tags/v0.1.52 -q '.assets[]|select(.name=="lupin-0.1.52-x86_64-unknown-linux-gnu.tar.gz")|.digest')"
sha256sum lupin-0.1.52-x86_64-unknown-linux-gnu.tar.gz
rm -rf x && mkdir x && tar -xzf lupin-0.1.52-x86_64-unknown-linux-gnu.tar.gz -C x || exit 1
B=$(find x -type f -name lupin | head -1); echo "binary $B"; sha256sum $B; $B --version
C=$L/web/upstream/wolf-lang
test "$(git -C $C rev-parse HEAD)" = 6ffe7c6056eeb8c661b37e38d99b91166e8c1add || exit 1
for f in os/signal_shell_rows.lu os/job_rows.lu grammar/cfg_target_arch.lu conc/atomic_counter.lu memory/raw_repr_c_layout.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu membrane/extern_libc.lu os/chdir_relative.lu os/env_unset.lu; do
  echo "== $f"; (cd $C/corpus && timeout 60 $L/native/$B run $f; echo "exit=$?") 2>&1 | tail -18
done
for n in os_pid os_ppid os_signal_send os_signal_number os_signal_ignored; do
  echo "== probes/$n.lu"; (cd $L/probes && timeout 60 $L/native/$B run $n.lu; echo "exit=$?") 2>&1 | tail -6
done
echo NATIVE-DONE
