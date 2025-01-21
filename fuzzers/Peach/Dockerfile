
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

# 安装Mono 4.8.1
RUN cd /usr/bin && \
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
WORKDIR /root/
RUN mkdir tasks
COPY --chown=ubuntu:ubuntu Peach /root/Peach/
COPY --chown=ubuntu:ubuntu collect_faults.py /root/collect_faults.py
COPY --chown=ubuntu:ubuntu collect_iteration.py /root/collect_iteration.py
COPY --chown=ubuntu:ubuntu --chmod=755 run.sh /root/run.sh
RUN sed -i 's/\r$//' run.sh

RUN wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz && \
    tar -zxvf node_exporter-1.7.0.linux-amd64.tar.gz && \
    mv node_exporter-1.7.0.linux-amd64 node_exporter


# 容器启动命令
CMD ["bash"]

