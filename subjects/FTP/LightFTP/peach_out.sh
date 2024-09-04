#!/bin/bash

# 定义清理函数
function cleanup {
    echo "开始清理 ${project}[$$]"
    pkill -P $$  # 杀死所有子进程

    # 获取网络命名空间中的进程 ID
    pids=$(ip netns pids${netns})

    echo "开始清理 ${netns}, pids:${pids}"
    # 杀死进程
    for pid in $pids; do
        kill -9 $pid
    done
}

# 设置 trap 来捕获退出信号并执行清理函数
trap cleanup EXIT

# 参数解析
FUZZER=$1
TIMEOUT=$2
container_pit_path=$3

# 协议和项目名称
protocol=ftp
project=lightftp
port=21

# 当前时间
ttime=`date +%Y-%m-%d-%T`
t="peach_ftp-${ttime}"

# 创建临时文件路径
cov_edge_path="/dev/shm/edge_${t}"
cov_bitmap_path="/dev/shm/bitmap_${t}"

# 创建临时文件
dd if=/dev/zero of=${cov_edge_path}  bs=10M count=1
dd if=/dev/zero of=${cov_bitmap_path} bs=10M count=1
export LUCKY_GLOBAL_MMAP_FILE=${cov_edge_path}

# 创建临时目录
mkdir branch

# 运行收集器
python3 /root/collect.py ${cov_edge_path} \
    "./branch/collect_branch_mutable_${project}_${t}_${port}" &

# Peach 模糊测试的路径
FUZZER_PATH=/root/${FUZZER}
export LUCKY_GLOBAL_MMAP_FILE=${cov_edge_path} SHM_ENV_VAR=${cov_bitmap_path} 
export PATH=${FUZZER_PATH}:$PATH LD_LIBRARY_PATH=${FUZZER_PATH}:$LD_LIBRARY_PATH 
timeout ${TIMEOUT} mono ${FUZZER_PATH}/protocol-fuzzer-ce/output/linux_x86_64_release/bin/peach.exe ${container_pit_path} &

while true; do echo 'Worker: Hit CTRL+C'; sleep 1800; done
