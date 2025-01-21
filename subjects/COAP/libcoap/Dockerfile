# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置非交互式前端，防止apt-get安装过程中出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表，安装所需软件包
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    unzip \
    git build-essential \
    llvm llvm-dev clang \
    autoconf automake pkg-config libtool libtool-bin

# 设置工作目录
WORKDIR /root/

# 安装其他依赖包
RUN apt-get install -y \
    gnutls-dev libgnutls28-dev lcov

# 克隆 pcguard-cov 仓库
RUN git clone https://github.com/csu-wingmate/pcguard-cov.git

# 切换到 pcguard-cov 目录并解压文件
WORKDIR /root/pcguard-cov
RUN unzip -o pcguard-cov.zip
# 编译 pcguard-cov
RUN make
RUN cp collect.py /root/collect.py
RUN cp collect_prometheus.py /root/collect_prometheus.py

# 切换到 llvm_mode 目录并编译
WORKDIR /root/pcguard-cov/llvm_mode
RUN AFL_TRACE_PC=1 make

WORKDIR /root
RUN git clone https://github.com/obgm/libcoap.git
WORKDIR /root/libcoap 
ENV CC=/root/pcguard-cov/afl-clang-fast CXX=/root/pcguard-cov/afl-clang-fast++
ENV CFLAGS="-Wall -O2 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fsanitize-coverage=trace-pc-guard" CXXFLAGS="-Wall -O2 -g -fsanitize=address,undefined -fno-omit-frame-pointer -fsanitize-coverage=trace-pc-guard"
ENV LDFLAGS="-fsanitize=address,undefined"
ENV AFL_USE_ASAN=1 ASAN_OPTIONS=detect_leaks=0
RUN ./autogen.sh && \
    ./configure --disable-doxygen --disable-manpages --enable-tests --disable-documentation --enable-examples --disable-shared --disable-tests && \
    make -j

WORKDIR /root
COPY --chown=ubuntu:ubuntu --chmod=755 run.sh /root/run.sh


# 容器启动命令
CMD ["bash"]
