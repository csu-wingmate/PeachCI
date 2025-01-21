# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置非交互式前端，防止apt-get安装过程中出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区
ENV TZ=Asia/Shanghai

# 安装 tzdata 包并配置时区
RUN apt-get update && \
    apt-get install -y tzdata curl tar build-essential llvm llvm-dev sudo vim git && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 克隆代码库并创建目录
WORKDIR /root
RUN git clone https://github.com/THU-WingTecher/PeachStar.git && \
    mkdir tasks

# 设置工作目录并安装依赖
WORKDIR /root/PeachStar/compiler
RUN apt-get update && \
    apt-get install -y libtinfo5 && \
    ./install-clang.sh

# 编译项目
RUN make clean && make || true

# 删除旧的目标文件，如果存在，并尝试编译 llvm_mode
WORKDIR /root/PeachStar/compiler/llvm_mode
RUN rm ../../afl-llvm-pass.so || true && \
    make || true

# 安装额外的依赖并重新编译
WORKDIR /root/PeachStar/compiler
RUN apt-get install -y build-essential automake libtool libc6-dev-i386 python3-pip g++-multilib mono-complete software-properties-common  libtinfo5 python && \
    make clean && make


WORKDIR /root/PeachStar/peach-3.0.202-source
COPY --chown=ubuntu:ubuntu  control.c /root/PeachStar/peach-3.0.202-source/control.c
# 编译control.c并安装Peach
RUN clang control.c -fPIC -shared -o libpeachControl.so && \
    ./waf configure && \
    ./waf install && \
    bash setup_env.sh && \
    sudo cp libpeachControl.so /usr/local/lib && \
    sudo ldconfig

# 设置环境变量
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
WORKDIR /root/
COPY --chown=ubuntu:ubuntu collect_faults.py /root/collect_faults.py
COPY --chown=ubuntu:ubuntu collect_iteration.py /root/collect_iteration.py
COPY --chown=ubuntu:ubuntu --chmod=755 run.sh /root/run.sh
RUN sed -i 's/\r$//' run.sh

RUN wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz && \
    tar -zxvf node_exporter-1.7.0.linux-amd64.tar.gz && \
    mv node_exporter-1.7.0.linux-amd64 node_exporter


# 容器启动命令
CMD ["bash"]
