#!/usr/bin/python3

import time
import re
import os
import sys

output_file_path = sys.argv[1]
fuzzer = sys.argv[2]
protocol = sys.argv[3]

# 初始化一个字典来存储每个目录的已处理迭代次数
last_processed_iterations = {}

# 获取 /root/logs/ 目录下所有可能的测试目录
logs_directory = '/root/logs/'
pattern = re.compile(rf'{protocol}_run_\d+\.xml_Default_\d+')

while True:
    try:
        # 遍历 /root/logs/ 目录
        for dir_name in os.listdir(logs_directory):
            # 检查目录名是否符合预期格式
            if pattern.match(dir_name):
                status_file_path = os.path.join(logs_directory, dir_name, 'status.txt')

                # 检查 status.txt 文件是否存在
                if os.path.exists(status_file_path):
                    # 读取 status.txt 文件的最后一行
                    with open(status_file_path, 'r') as file:
                        lines = file.readlines()
                        last_line = lines[-1] if lines else ''

                    # 使用正则表达式从最后一行提取迭代次数
                    match = re.search(r"Iteration (\d+) of", last_line)
                    if match:
                        iteration_number = int(match.group(1))

                        # 如果目录是新发现的，初始化迭代次数
                        if dir_name not in last_processed_iterations:
                            last_processed_iterations[dir_name] = 0

                        # 仅当发现新的迭代时才写入输出文件
                        if iteration_number > last_processed_iterations[dir_name]:
                            # 检查输出文件是否存在并删除它以重新开始
                            if os.path.exists(output_file_path):
                                os.remove(output_file_path)

                            with open(output_file_path, "a") as f:  # 打开文件以追加模式
                                f.write(f'Iteration_{fuzzer}_{dir_name}{{job="Iteration"}} {iteration_number}\n')
                                print(f"Updated current iteration for {dir_name}: {iteration_number}")

                            # 更新已处理的迭代次数
                            last_processed_iterations[dir_name] = iteration_number
                else:
                    print(f"Waiting for 'status.txt' to appear in {status_file_path}.")
                    time.sleep(1)  # 等待1秒后再次检查
                    continue  # 跳过当前循环的剩余部分

    except Exception as e:
        print(f"An error occurred: {e}")
    
    time.sleep(1)
