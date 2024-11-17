#!/bin/bash
TIMEOUT=$1
PROTOCOL=$2
i=$3
cd /dev/shm
dd if=/dev/zero bs=10M count=1 of=$name-of-shared-memory
export SHM_ENV_VAR=/dev/shm/$name-of-shared-memory

timeout ${TIMEOUT} mono /root/PeachStar/output/linux_x86_64_release/bin/peach.exe -pro /root/tasks/${PROTOCOL}_run_${i}.xml &

while true; do echo 'Worker: Hit CTRL+C'; sleep 1800; done
