import matplotlib.pyplot as plt
import os
import argparse

# 解析命令行参数
parser = argparse.ArgumentParser(description='Generate coverage over time plot.')
parser.add_argument('-d', '--directory', required=True, help='Directory path containing the results.')
parser.add_argument('-t', '--time', type=int, required=True, help='Maximum time in hours.')
parser.add_argument('-o', '--output', required=True, help='Output image file name.')
args = parser.parse_args()

# 定义一个函数来读取和解析文件
def read_and_parse(file_name, max_time_seconds):
    try:
        with open(file_name, "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"File {file_name} not found. Skipping...")
        return [], []

    data = []
    for line in lines:
        time, coverage = line.strip().split(", ")
        time = int(time)
        coverage = int(coverage)
        if time > max_time_seconds:
            continue  # 跳过超过最大时间的数据
        data.append((time, coverage))
    
    # 如果数据没有达到最大时间，补充一行数据
    if data and data[-1][0] < max_time_seconds:
        max_coverage = max(c for _, c in data)
        data.append((max_time_seconds, max_coverage))

    return data

# 设置目录路径和最大时间值（小时）
directory_path = args.directory
max_time_hours = args.time
max_time_seconds = max_time_hours * 3600

# 获取指定目录下所有以 "collect_branch_mutable_" 开头的文件
file_names = [f for f in os.listdir(directory_path) if f.startswith("collect_branch_mutable_")]

# 初始化一个字典来保存所有数据
all_data = {}

# 读取所有文件
for file_name in file_names:
    file_path = os.path.join(directory_path, file_name)
    all_data[file_name] = read_and_parse(file_path, max_time_seconds)

# 提取时间序列和分支覆盖数，并绘制折线图
for file_name, data in all_data.items():
    if data:
        times, coverages = zip(*data)
        times_hours = [t / 3600 for t in times]
        plt.plot(times_hours, coverages, label=file_name)


plt.xlabel("time(h)")
plt.ylabel("branch")
plt.title("openssl(TLS)")
plt.legend()
plt.savefig(args.output)  # 保存图像
plt.show()

