
# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置非交互式前端，防止apt-get安装过程中出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区
ENV TZ=Asia/Shanghai

# 安装 tzdata 包
RUN apt-get update && \
    apt-get install -y tzdata

# 配置时区
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# 更新包列表，安装所需软件包，配置时区
RUN apt-get update && \
    apt-get update && apt install -y sudo vim git tar    
 
WORKDIR /root
RUN git clone https://github.com/THU-WingTecher/PeachStar.git

# 安装依赖
RUN apt-get update && apt-get install -y curl tar build-essential llvm llvm-dev

# 设置工作目录
WORKDIR /root/PeachStar/compiler

# 运行安装脚本
RUN ./install-clang.sh

# 安装额外的依赖
RUN apt-get install -y libtinfo5

# 编译项目
RUN make || true

# 设置工作目录为 llvm_mode
WORKDIR /root/PeachStar/compiler/llvm_mode

# 尝试编译 llvm_mode，如果失败则继续执行
RUN make || true

# 删除旧的目标文件，如果存在
RUN rm ../afl-llvm-pass.so || true

WORKDIR /root/PeachStar/compiler
RUN make clean && make && \
    sudo apt-get install -y build-essential  \
    automake  \
    libtool  \
    libc6-dev-i386 \
    python3-pip \
    g++-multilib \
    mono-complete \
    software-properties-common \
    libtinfo5 \
    python

WORKDIR /root/PeachStar/peach-3.0.202-source
COPY --chown=ubuntu:ubuntu  control.c /root/PeachStar/peach-3.0.202-source/control.c
RUN clang control.c -fPIC -shared -o libpeachControl.so && \
    ./waf configure && \
    ./waf install && \
    bash setup_env.sh && \
    sudo cp /root/PeachStar/peach-3.0.202-source/libpeachControl.so /usr/local/lib && \
    sudo ldconfig && \
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH && \
    cd /dev/shm && \
    dd if=/dev/zero bs=10M count=1 of=$name-of-shared-memory && \
    export SHM_ENV_VAR=/dev/shm/$name-of-shared-memory 
    
# 设置工作目录
WORKDIR /root/PeachStar/peach-3.0.202-source/output/linux_x86_64_release/bin
# 设置环境变量 FUZZERPATH 为当前工作目录的路径
ENV FUZZERPATH $PWD

# 容器启动命令
CMD ["bash"]

