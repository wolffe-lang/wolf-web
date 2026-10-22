#!/bin/bash
# ww46: launch ~/lanes/ww46/<name>.sh detached (setsid -f); the job writes its own pid to <name>.pid as its first act
# and <name>.status (its exit code) as its last; output to <name>.out. Kill only by that recorded pid.
n=$1; shift
cd ~/lanes/ww46 || exit 1
rm -f ~/lanes/ww46/$n.pid ~/lanes/ww46/$n.status
setsid -f bash -c 'echo $$ > ~/lanes/ww46/'"$n"'.pid; bash ~/lanes/ww46/'"$n"'.sh "$@"; echo $? > ~/lanes/ww46/'"$n"'.status' _ "$@" > ~/lanes/ww46/$n.out 2>&1 < /dev/null
sleep 1; echo "launched $n pid $(cat ~/lanes/ww46/$n.pid 2>/dev/null)"
