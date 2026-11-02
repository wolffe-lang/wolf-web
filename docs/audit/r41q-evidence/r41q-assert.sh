#!/usr/bin/env bash
# web-assert.sh : r41q's last terminal check, frozen once queued. lupin 0.1.58 alone in a container
# (--init, no network): (1) the two assert-message faults the tab's header check found parting, as
# `lupin run FILE --json` prints their records, to see what a terminal's stdout_inline carries; (2) the
# two copy_chunk arrivals again with `target/` present, as the compiler's repository has it (the
# arrivals pass ran them first, before any program had made `target/`, and they answered not_found).
set -u
R=/home/mfwolffe/lanes/r41q
M=$R/web/measure
NEW=$R/web/new
LUPIN=$R/archives/lupin-0.1.58-x86_64-unknown-linux-gnu/lupin-0.1.58-x86_64-unknown-linux-gnu/lupin
IMG=localhost/r41q-pack-ci:fbee7e864f7dbee6
CPUS=${R41Q_CPUS:?run under bin/block2}
export PATH=$HOME/lanes/hasu-env/bin:$HOME/lanes/hasu-env/profile/bin:$PATH
echo "== STEP assert $(date -u +%FT%TZ)"
T=$M/terminal-assert
rm -rf "$T" && mkdir -p "$T" && cp -r "$NEW/upstream/wolf-lang/corpus" "$T/corpus" && cp "$LUPIN" "$T/lupin" || { echo "END assert exit=1"; exit 1; }
cat > "$T/run.sh" <<'EOS'
#!/bin/bash
ulimit -c 0
cd /t/corpus
/t/lupin --version
for f in faults/assert_msg_effect_fails.lu faults/assert_msg_name_fails.lu; do
  echo "-- $f --json"; timeout 60 /t/lupin run "$f" --json < /dev/null; echo "exit=$?"
  echo "-- $f plain"; timeout 60 /t/lupin run "$f" < /dev/null 2>/t/err; echo "exit=$?"; echo "stderr: $(tr '\n' '|' < /t/err | head -c 300)"
done
mkdir -p target
for f in fs/copy_chunk_failed_write.lu fs/copy_chunk_dev_full.lu; do
  echo "-- $f (target/ present)"; timeout 60 /t/lupin run "$f" < /dev/null 2>/t/err; echo "exit=$?"; echo "stderr: $(tr '\n' '|' < /t/err | head -c 300)"
done
EOS
chmod +x "$T/run.sh"
podman run --rm --init --memory 12g --network none -v "$T:/t" "$IMG" taskset -c "$CPUS" /t/run.sh > "$M/terminal-assert-0.1.58.txt" 2>&1
rc=$?
cat "$M/terminal-assert-0.1.58.txt"
echo "END assert exit=$rc"
echo "R41Q_ASSERT_DONE $(date -u +%FT%TZ)"
