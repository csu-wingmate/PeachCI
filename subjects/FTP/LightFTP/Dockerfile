
# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置非交互式前端，防止apt-get安装过程中出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表，安装所需软件包，配置时区
RUN apt-get update && \
    apt-get install -y sudo vim && \
    echo "set nu" >>  ~/.vimrc && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    tzdata \
    coreutils apt-utils wget curl openssl ca-certificates bash-completion \
    joe nano \
    unzip p7zip \
    fping hping3 httping thc-ipv6 gdb \
    tcpdump wireshark-common \
    locales-all \
    git build-essential strace tcpdump \
    ruby doxygen libxml2-utils less openjdk-8-jre xsltproc asciidoctor \
    nodejs node-typescript wget \
    apt-transport-https dirmngr gnupg ca-certificates apt-utils \
    cmake dos2unix \
    libglib2.0-dev libcairo2-dev \
    autoconf \
    llvm llvm-dev clang \
    && echo "tzdata tzdata/Areas select Asia" | debconf-set-selections \
    && echo "tzdata tzdata/Zones/Asia select Shanghai" | debconf-set-selections \
    && echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# 设置时区环境变量
ENV TZ=Asia/Shanghai


# 添加Mono仓库并安装Mono
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list && \
    sudo apt-get update && \
    sudo apt-get install mono-devel -y

# 克隆协议模糊测试器并准备环境
RUN cd /root/ && \
    mkdir Peach && \
    cd Peach && \
    git clone https://gitlab.com/gitlab-org/security-products/protocol-fuzzer-ce.git && \
    cd protocol-fuzzer-ce/3rdParty/pin && \
    wget http://software.intel.com/sites/landingpage/pintool/downloads/pin-3.2-81205-gcc-linux.tar.gz && \
    tar -xf pin-3.2-81205-gcc-linux.tar.gz && \
    cd ../../paket/.paket && \
    wget https://github.com/fsprojects/Paket/releases/download/5.258.1/paket.exe && \
    wget https://github.com/fsprojects/Paket/releases/download/5.258.1/paket.bootstrapper.exe && \
    wget https://github.com/fsprojects/Paket/releases/download/5.258.1/paket.targets && \
    wget https://github.com/fsprojects/Paket/releases/download/5.258.1/Paket.Restore.targets && \
    cd ../../3rdParty/pin && \
    wget https://software.intel.com/sites/landingpage/pintool/downloads/pin-3.19-98425-gd666b2bee-gcc-linux.tar.gz && \
    tar -zxvf pin-3.19-98425-gd666b2bee-gcc-linux.tar.gz && \
    mv ./pin-3.19-98425-gd666b2bee-gcc-linux ./pin-3.19-98425-gcc-linux

COPY --chown=ubuntu:ubuntu bblocks.cpp /root/Peach/protocol-fuzzer-ce/core/BasicBlocks/bblocks.cpp

# 编译协议模糊测试器
RUN cd /root/Peach/protocol-fuzzer-ce/ && \
    apt-get update && \
    apt-get install -y python2 && \
    python2 waf configure --buildtag=0.0.2 && \
    python2 waf build

# 安装Mono 4.8.1
RUN sudo apt-get autoremove mono-devel -y && \
    cd /usr/bin && \
    wget https://download.mono-project.com/sources/mono/mono-4.8.1.0.tar.bz2 && \
    tar -jxvf mono-4.8.1.0.tar.bz2 && \
    cd mono-4.8.1 && \
    sudo apt-get install -y libtool-bin && \
    ./autogen.sh && \
    make get-monolite-latest

COPY --chown=ubuntu:ubuntu processes.c /usr/bin/mono-4.8.1/mono/io-layer/processes.c
# 切换到源代码目录
WORKDIR /usr/bin/mono-4.8.1

# 编译Mono
RUN sudo make && \
    sudo make install
    
# 切换到源代码目录
WORKDIR /etc/    
    
COPY --chown=ubuntu:ubuntu profile /etc/profile
# 执行profile文件来更新环境变量
RUN /bin/bash /etc/profile

# 切换到源代码目录
WORKDIR /root/Peach/protocol-fuzzer-ce/

# 安装协议模糊测试器
RUN python2 waf install

# 设置工作目录
WORKDIR /root/

# 安装其他依赖包
RUN apt-get install -y \
    gnutls-dev libgnutls28-dev lcov

# 克隆 pcguard-cov 仓库
RUN git clone https://gitee.com/xz_chenwanli/pcguard-cov.git

# 切换到 pcguard-cov 目录并解压文件
WORKDIR /root/pcguard-cov
RUN unzip -o pcguard-cov.zip

# 编译 pcguard-cov
RUN make

# 切换到 llvm_mode 目录并编译
WORKDIR /root/pcguard-cov/llvm_mode
COPY --chown=ubuntu:ubuntu Makefile /root/pcguard-cov/llvm_mode/Makefile
RUN AFL_TRACE_PC=1 make

# 克隆 LightFTP 仓库
WORKDIR /root

COPY --chown=ubuntu:ubuntu collect.py /root/collect.py

RUN mkdir experiments && \
    cd experiments && \
    git clone https://github.com/hfiref0x/LightFTP.git LightFTP

# 切换到 LightFTP/Source/Release 目录并使用 afl-clang-fast 编译
WORKDIR /root/experiments/LightFTP/Source/Release
RUN CC=/root/pcguard-cov/afl-clang-fast CXX=/root/pcguard-cov/afl-clang-fast++ AFL_USE_ASAN=1 make

WORKDIR /root/experiments

COPY --chown=ubuntu:ubuntu peach_parallel_out.sh /root/experiments/peach_parallel_out.sh
RUN mkdir tasks



# 暴露端口（如果需要）
EXPOSE 8080

# 容器启动命令
CMD ["bash"]

