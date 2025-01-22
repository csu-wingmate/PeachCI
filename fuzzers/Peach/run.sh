#!/bin/bash

TIMEOUT=$1
PROTOCOL=$2
i=$3
OPTION=$4

# 启动后台Python进程
python3 collect_faults.py potential_vulnerability.prom peach ${PROTOCOL}${i} &
FAULTS_PID=$!

python3 collect_iteration.py iteration.prom peach ${PROTOCOL}${i} &
ITERATION_PID=$!

# 根据OPTION参数启动Peach Fuzzer
if [[ $OPTION == -p* ]]; then
    work_num=$(echo "$OPTION" | cut -d' ' -f2)
    for j in $(seq 1${work_num}) ; do
        timeout ${TIMEOUT} mono /root/Peach/bin/peach.exe \
        /root/tasks/${PROTOCOL}_run_${i}.xml -p${work_num},${j} &
        PEACH_PIDS+=" $!"
        sleep 1
    done
else
    timeout ${TIMEOUT} mono /root/Peach/bin/peach.exe${OPTION} /root/tasks/${PROTOCOL}_run_${i}.xml &
    PEACH_PID=$!
fi

# 等待Peach Fuzzer超时结束
wait $PEACH_PID

# 等待1秒后，强制停止所有Python进程
sleep 1
pkill -P $FAULTS_PID
pkill -P $ITERATION_PID

# 如果有多个Peach Fuzzer进程，也停止它们
if [[ -n $PEACH_PIDS ]]; then
    for pid in $PEACH_PIDS; do
        pkill -P $pid
    done
fi
