#!/bin/bash
TIMEOUT=$1
PROTOCOL=$2
i=$3
OPTION=$4

cd /dev/shm
dd if=/dev/zero bs=10M count=1 of=$name-of-shared-memory
export LD_LIBRARY_PATH=/root/Charon/:$LD_LIBRARY_PATH
export SHM_ENV_VAR=/dev/shm/$name-of-shared-memory

python3 collect_faults.py potential_vulnerability.prom charon ${PROTOCOL} ${i} &

python3 collect_iteration.py iteration.prom charon ${PROTOCOL} ${i} &

if [[ $OPTION == -p* ]]; then
    work_num=$(echo "$OPTION" | cut -d' ' -f2)
    for j in $(seq 1${work_num}) ; do
        timeout ${TIMEOUT} mono /root/Charon/executable/charon.exe \
        /root/tasks/${PROTOCOL}_run_${i}.xml -p${work_num},${j} &
        sleep 1
    done
else
    # 如果OPTION不是以"-p"开头，则执行Charon
    timeout ${TIMEOUT} mono /root/Charon/executable/charon.exe ${OPTION} /root/tasks/${PROTOCOL}_run_${i}.xml &
fi
