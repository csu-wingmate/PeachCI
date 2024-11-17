#!/bin/bash
TIMEOUT=$1
PROTOCOL=$2
i=$3
cd /dev/shm
dd if=/dev/zero bs=10M count=1 of=$name-of-shared-memory
export LD_LIBRARY_PATH=/root/Charon/:$LD_LIBRARY_PATH
export SHM_ENV_VAR=/dev/shm/$name-of-shared-memory

timeout ${TIMEOUT} mono /root/Charon/executable/charon.exe /root/tasks/${PROTOCOL}_run_${i}.xml &

while true; do echo 'Worker: Hit CTRL+C'; sleep 1800; done
