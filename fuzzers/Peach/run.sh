#!/bin/bash

TIMEOUT=$1
PROTOCOL=$2
i=$3
OPTION=$4

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

# 无限循环，可以按CTRL+C退出
while true; do
    echo 'Worker: Hit CTRL+C to exit'
    sleep 1800
done

