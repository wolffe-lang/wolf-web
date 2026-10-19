#!/bin/bash
# ww45: launch ~/lanes/ww45/<name>.sh detached (setsid), log to <name>.out, pid to <name>.pid
n=$1; shift
cd ~/lanes/ww45 || exit 1
setsid bash ~/lanes/ww45/$n.sh "$@" > ~/lanes/ww45/$n.out 2>&1 < /dev/null &
echo $! > ~/lanes/ww45/$n.pid
echo "launched $n pid $(cat ~/lanes/ww45/$n.pid)"
