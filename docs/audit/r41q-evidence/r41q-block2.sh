#!/usr/bin/env bash
# block2 A|B CMD... : run CMD on hasu block A (CPUs 0-5) or B (CPUs 6-11) under one long flock per
# lock name, the block name outside (the lane rules' 2026-11-01 batch-A rule: never a short-wait
# retry loop, which re-queues the waiter at the back). CMD sees the block's CPUs as $R41Q_CPUS.
L=/home/mfwolffe/lanes
b=$1
shift
case "$b" in
A) cpus=0-5 ;;
B) cpus=6-11 ;;
*) echo "block2: A or B, not $b" >&2; exit 2 ;;
esac
export R41Q_CPUS=$cpus
echo "block2: waiting for block $b from $(date -u +%FT%TZ)"
exec flock -w 21600 "$L/hasu-block-$b.lock" flock -w 21600 "$L/hasu-$b.lock" taskset -c "$cpus" "$@"
