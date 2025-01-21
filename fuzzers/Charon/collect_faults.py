#!/usr/bin/python3
import time
import os
import sys
import socket
import re

# 从命令行参数获取信息
output_file_path = sys.argv[1]
fuzzer = sys.argv[2]
protocol = sys.argv[3]
i = sys.argv[4]

# 获取本机 IP 地址
def get_host_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    finally:
        s.close()
    return ip

host_ip = get_host_ip()

# 初始化一个字典来存储故障名称及其数量
while True:
    # 检查 /root/logs/ 目录是否存在
    logs_directory = '/root/logs/'
    if os.path.exists(logs_directory):
        # 正则表达式匹配以 {protocol}_{i}.xml_ 开头的目录
        pattern = re.compile(rf'{protocol}_run_\d+\.xml_')
        # 遍历 /root/logs/ 目录
        for dir_name in os.listdir(logs_directory):
            # 检查目录名是否符合预期格式
            if pattern.match(dir_name):
                fault_directory = os.path.join(logs_directory, dir_name, 'Faults')
                
                # 检查 Faults 目录是否存在
                if os.path.exists(fault_directory):
                    fault_counts = {}

                    # 遍历 Faults 目录
                    for fault_name in os.listdir(fault_directory):
                        fault_path = os.path.join(fault_directory, fault_name)
                        
                        # 检查是否为目录而不是文件
                        if os.path.isdir(fault_path):
                            # 计算子目录的数量（潜在的漏洞）
                            subdirectory_count = len([name for name in os.listdir(fault_path) if os.path.isdir(os.path.join(fault_path, name))])
                            fault_counts[fault_name] = subdirectory_count

                    # 检查输出文件是否存在并删除它
                    if os.path.exists(output_file_path):
                        os.remove(output_file_path)

                    # 如果存在故障，写入 Prometheus 指标
                    if fault_counts:
                        with open(output_file_path, 'w') as prom_file:
                            for fault_name, count in fault_counts.items():
                                # 写入 Prometheus 指标行
                                prom_file.write(f'{fuzzer}_{protocol}_{i}_bugs{{host="{host_ip}", bug_host="{fault_directory}", bug_name="{fault_name}", number="{count}", fuzzer="{fuzzer}", protocol_implement="{protocol}"}} 1\n')
                                # 打印故障名称及其数量
                                print(f"Host: {host_ip}, Bug Host: {fault_directory}, Bug Name: {fault_name}, Number: {count}, Fuzzer: {fuzzer}, Protocol Implement: {protocol}")
                    else:
                        print(f"No faults found in {fault_directory}.")
                else:
                    print(f"Waiting for 'Faults' directory to appear in {fault_directory}.")
                    time.sleep(1)  # 等待1秒后再次检查
                    continue  # 跳过当前循环的剩余部分
    else:
        print(f"Directory {logs_directory} does not exist. Waiting for it to appear...")

    # 在更新之前等待指定的时间间隔
    time.sleep(1)
