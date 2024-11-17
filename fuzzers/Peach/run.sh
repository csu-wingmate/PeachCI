#!/bin/bash
TIMEOUT=$1
PROTOCOL=$2
i=$3

timeout ${TIMEOUT} mono /root/Peach/bin/peach.exe /root/tasks/${PROTOCOL}_run_${i}.xml &

while true; do echo 'Worker: Hit CTRL+C'; sleep 1800; done
