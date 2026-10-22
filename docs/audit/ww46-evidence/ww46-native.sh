# ww46 (adapted from ww45-native.sh): the published lupin 0.1.55 and wolf 0.2.34 linux x86-64 archives (kasumi; the pair
# archives.sh unpacked from reads equal to GitHub's digests, std/ beside wolf as the archive places it; lupin alone in its
# own folder, as installed alone and as the tab has it, so `use std.…` does not resolve under it), at a terminal (no tty:
# stdin /dev/null): the seven 0.2.34 calls one each, §34.7's and §34.8's four programs, ww45's eleven 0.2.33 probes and
# the corpus's os rows, under lupin, the checked machine (wolf conform-run --json --checked) and native (wolf run).
# RULES.md §5: everything runs INSIDE ITS OWN PID NAMESPACE (an unprivileged user namespace with the lane's uid mapped,
# --pid --fork --mount-proc, RLIMIT_CORE 0), never on kasumi's process table: §34.7's programs fork, §34.8's wait.lu
# raises a resize at itself, ww45's one.lu sends itself a SEGV and again.lu's child ends itself by a signal.
L=~/lanes/ww46
if [ -z "$WW46_IN_NS" ]; then
  exec unshare --user --map-current-user --pid --fork --mount-proc env WW46_IN_NS=1 bash $L/native.sh
fi
ulimit -c 0
echo "namespace: pid $$ procs $(ls -d /proc/[0-9]* | wc -l) uid $(id -u) core $(ulimit -c)/$(ulimit -Hc)"
grep -E '^Sig(Blk|Ign)' /proc/self/status
unset WOLF_STD LUPIN_STD
P=$L/pair; B=$P/lupin-0.1.55-x86_64-unknown-linux-gnu/lupin; W=$P/wolf-0.2.34-x86_64-unknown-linux-gnu/wolf
echo "lupin $B"; $B --version; echo "wolf $W"; $W --version; echo "wolf's std/ STD-REV $(cat $(dirname $W)/std/STD-REV)"
C=$L/web/upstream/wolf-lang
test "$(git -C $C rev-parse HEAD)" = 9da7bdcf2aea9adf48df6570bedc58e16e9ef853 || { echo "corpus not at v0.2.34"; exit 1; }
for f in os/signal_one_rows.lu os/group_rows.lu os/job_poll_rows.lu os/term_editor_rows.lu; do
  echo "== lupin $f"; (cd $C/corpus && timeout 60 $B run $f < /dev/null; echo "exit=$?") 2>&1 | tail -16
  echo "== wolf checked $f"; (cd $C/corpus && timeout 120 $W conform-run --json --checked $f < /dev/null | head -c 900; echo; echo "exit=${PIPESTATUS[0]}") 2>&1 | tail -6
  echo "== wolf run (native) $f"; (cd $C/corpus && timeout 120 $W run $f < /dev/null; echo "exit=$?") 2>&1 | tail -16
done
T=$L/tmp-native; rm -rf "${L:?}/tmp-native"; mkdir -p $T
for d in $L/probes $L/web/docs/audit/ww45-evidence/probes; do
  for f in $(cd $d && ls *.lu); do p=${f%.lu}; rm -rf "${T:?}/$p"; mkdir -p $T/$p && cp $d/$f $T/$p/
    echo "== lupin $(basename $(dirname $d/$f))/$f"; (cd $T/$p && timeout 60 $B run $f < /dev/null; echo "exit=$?") 2>&1 | tail -10
    echo "== wolf checked $(basename $(dirname $d/$f))/$f"; (cd $T/$p && timeout 120 $W conform-run --json --checked $f < /dev/null | head -c 900; echo; echo "exit=${PIPESTATUS[0]}") 2>&1 | tail -6
    echo "== wolf run (native) $(basename $(dirname $d/$f))/$f"; (cd $T/$p && timeout 120 $W run $f < /dev/null; echo "exit=$?") 2>&1 | tail -10
  done
done
rm -rf "${L:?}/tmp-native"
echo NATIVE-DONE
