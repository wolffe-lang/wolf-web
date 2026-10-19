# ww44 (adapted from ww43-native.sh): the published lupin 0.1.54 and wolf 0.2.32 linux archives (kasumi), digests
# against GitHub's, then at a terminal (no tty: stdin /dev/null, stdout a file) the rows the pages name, the arrivals,
# the seven 0.2.31 builtins' probes, §34.5's three programs and §3.3's two; the probes also through the 0.2.32 checked machine
# (wolf conform-run --json --checked), which is the compiler's answer for each, and wolf run (native).
L=~/lanes/ww44; mkdir -p $L/native && cd $L/native || exit 1
for u in https://github.com/wolffe-lang/wolf-interp/releases/download/v0.1.54/lupin-0.1.54-x86_64-unknown-linux-gnu.tar.gz https://github.com/wolffe-lang/wolf-lang/releases/download/v0.2.32/wolf-0.2.32-x86_64-unknown-linux-gnu.tar.gz; do curl -sfLO $u || exit 1; done
echo "published lupin $(gh api repos/wolffe-lang/wolf-interp/releases/tags/v0.1.54 -q '.assets[]|select(.name=="lupin-0.1.54-x86_64-unknown-linux-gnu.tar.gz")|.digest')"
echo "published wolf  $(gh api repos/wolffe-lang/wolf-lang/releases/tags/v0.2.32 -q '.assets[]|select(.name=="wolf-0.2.32-x86_64-unknown-linux-gnu.tar.gz")|.digest')"
sha256sum lupin-0.1.54-x86_64-unknown-linux-gnu.tar.gz wolf-0.2.32-x86_64-unknown-linux-gnu.tar.gz
rm -rf x && mkdir x && tar -xzf lupin-0.1.54-x86_64-unknown-linux-gnu.tar.gz -C x && tar -xzf wolf-0.2.32-x86_64-unknown-linux-gnu.tar.gz -C x || exit 1
B=$L/native/$(cd $L/native && find x -type f -name lupin | head -1); W=$L/native/x/wolf-0.2.32-x86_64-unknown-linux-gnu/wolf
echo "lupin $B"; $B --version; echo "wolf $W"; $W --version
C=$L/web/upstream/wolf-lang
test "$(git -C $C rev-parse HEAD)" = 72de141f624662fdff522e8beba459fab7c5cf66 || { echo "corpus not at v0.2.32"; exit 1; }
for f in comptime/shift_value.lu faults/int_shift_left_overflow.lu kernels/wrap_lshr_fold.lu os/group_rows.lu os/job_poll_rows.lu typecheck/int_shift_value.lu typecheck/straight_line_shr_var.lu conc/proc_must_join_legal.lu os/ids_read.lu os/ids_rows.lu os/term_editor_rows.lu os/signal_shell_rows.lu os/job_rows.lu grammar/cfg_target_arch.lu conc/atomic_counter.lu memory/raw_repr_c_layout.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu membrane/extern_libc.lu os/chdir_relative.lu; do
  echo "== lupin $f"; (cd $C/corpus && timeout 60 $B run $f < /dev/null; echo "exit=$?") 2>&1 | tail -12
done
P=$L/probes
for f in $(cd $P && ls *.lu); do
  echo "== lupin probes/$f"; (cd $P && timeout 60 $B run $f < /dev/null; echo "exit=$?") 2>&1 | tail -10
done
for f in $(cd $P && ls *.lu); do
  echo "== wolf checked probes/$f"; (cd $P && timeout 120 $W conform-run --json --checked $f < /dev/null | head -c 600; echo; echo "exit=$?") 2>&1 | tail -6
  echo "== wolf run (native) probes/$f"; (cd $P && timeout 120 $W run $f < /dev/null; echo "exit=$?") 2>&1 | tail -10
done
echo NATIVE-DONE
