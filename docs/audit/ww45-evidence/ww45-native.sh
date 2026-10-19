# ww45 (adapted from ww44-native.sh): the published lupin 0.1.54 and wolf 0.2.33 linux archives (kasumi; the pair
# ww45-archives.sh unpacked from reads equal to GitHub's digests, std/ beside wolf as the archive places it), then at a
# terminal (no tty: stdin /dev/null) the arrivals and the probes: lupin on each, and the 0.2.33 checked machine
# (wolf conform-run --json --checked) and native (wolf run), which are the compiler's answers.
# RULES.md §5: everything runs INSIDE ITS OWN PID NAMESPACE (an unprivileged user namespace with the lane's uid mapped,
# --pid --fork --mount-proc, RLIMIT_CORE 0), never on kasumi's process table: §34.6's one.lu sends itself a SEGV and
# again.lu starts a child that ends itself by a signal; each reaches only what the namespace started.
L=~/lanes/ww45
if [ -z "$WW45_IN_NS" ]; then
  exec unshare --user --map-current-user --pid --fork --mount-proc env WW45_IN_NS=1 bash $L/ww45-native.sh
fi
ulimit -c 0
echo "namespace: pid $$ procs $(ls -d /proc/[0-9]* | wc -l) uid $(id -u) core $(ulimit -c)/$(ulimit -Hc)"
grep -E '^Sig(Blk|Ign)' /proc/self/status
unset WOLF_STD LUPIN_STD
P=$L/pair; B=$(find $P -type f -name lupin | head -1); W=$P/wolf-0.2.33-x86_64-unknown-linux-gnu/wolf
echo "lupin $B"; $B --version; echo "wolf $W"; $W --version; echo "wolf's std/: $(ls $(dirname $W)/std | tr '\n' ' '); STD-REV $(cat $(dirname $W)/std/STD-REV)"
C=$L/web/upstream/wolf-lang
git -C $C checkout -q 85dab5d7e597680d6fd7034f1d7ed2acb9a92f97 || exit 1
test "$(git -C $C rev-parse HEAD)" = 85dab5d7e597680d6fd7034f1d7ed2acb9a92f97 || { echo "corpus not at v0.2.33"; exit 1; }
for f in os/signal_one_rows.lu os/group_rows.lu os/job_poll_rows.lu; do
  echo "== lupin $f"; (cd $C/corpus && timeout 60 $B run $f < /dev/null; echo "exit=$?") 2>&1 | tail -16
  echo "== wolf checked $f"; (cd $C/corpus && timeout 120 $W conform-run --json --checked $f < /dev/null | head -c 900; echo; echo "exit=${PIPESTATUS[0]}") 2>&1 | tail -6
  echo "== wolf run (native) $f"; (cd $C/corpus && timeout 120 $W run $f < /dev/null; echo "exit=$?") 2>&1 | tail -16
done
T=$L/tmp-native; rm -rf "${L:?}/tmp-native"; mkdir -p $T
for f in $(cd $L/probes && ls *.lu); do p=${f%.lu}; mkdir -p $T/$p && cp $L/probes/$f $T/$p/
  echo "== lupin probes/$f"; (cd $T/$p && timeout 60 $B run $f < /dev/null; echo "exit=$?") 2>&1 | tail -10
  echo "== wolf checked probes/$f"; (cd $T/$p && timeout 120 $W conform-run --json --checked $f < /dev/null | head -c 700; echo; echo "exit=${PIPESTATUS[0]}") 2>&1 | tail -6
  echo "== wolf run (native) probes/$f"; (cd $T/$p && timeout 120 $W run $f < /dev/null; echo "exit=$?") 2>&1 | tail -10
done
git -C $C checkout -q 85dab5d7e597680d6fd7034f1d7ed2acb9a92f97 || exit 1
rm -rf "${L:?}/tmp-native"
echo NATIVE-DONE
