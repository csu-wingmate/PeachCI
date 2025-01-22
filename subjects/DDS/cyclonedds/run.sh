#!/bin/bash
FUZZER=$1
i=$2
# 协议和项目名称
protocol=dds
project=cyclonedds
port=7400

# 当前时间
ttime=`date +%Y-%m-%d-%T`
t="${FUZZER}_dds-${ttime}"

# 创建临时文件路径
cov_edge_path="/dev/shm/edge_${t}"
cov_bitmap_path="/dev/shm/bitmap_${t}"

# 创建临时文件
dd if=/dev/zero of=${cov_edge_path}  bs=10M count=1
dd if=/dev/zero of=${cov_bitmap_path} bs=10M count=1
export LUCKY_GLOBAL_MMAP_FILE=${cov_edge_path}

# 创建临时目录
mkdir /root/branch

# 运行收集器
python3 /root/collect.py ${cov_edge_path} \
    "/root/branch/${FUZZER}_branch_${project}_${t}_${port}" &
    
python3 /root/collect_prometheus.py ${cov_edge_path}  "/root/branch/${FUZZER}_branch_${project}_${t}_${port}.prom" ${FUZZER} ${project} ${i} &

# Peach 模糊测试的路径
export LUCKY_GLOBAL_MMAP_FILE=${cov_edge_path} SHM_ENV_VAR=${cov_bitmap_path} 
/root/cyclonedds/build/bin/HelloworldSubscriber
