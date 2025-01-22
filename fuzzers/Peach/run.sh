#!/bin/bash

TIMEOUT=$1
PROTOCOL=$2
i=$3
OPTION=$4

python3 collect_faults.py potential_vulnerability.prom peach ${PROTOCOL} ${i} &

python3 collect_iteration.py iteration.prom peach ${PROTOCOL} ${i} &

if [[ $OPTION == -p* ]]; then
    work_num=$(echo "$OPTION" | cut -d' ' -f2)
    for j in $(seq 1${work_num}) ; do
        timeout ${TIMEOUT} mono /root/Peach/bin/peach.exe \
        /root/tasks/${PROTOCOL}_run_${i}.xml -p${work_num},${j} &
        sleep 1
    done
else
    # 如果OPTION不是以"-p"开头，则执行Peach Fuzzer
    timeout ${TIMEOUT} mono /root/Peach/bin/peach.exe${OPTION} /root/tasks/${PROTOCOL}_run_${i}.xml &
fi

