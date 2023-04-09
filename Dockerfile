# syntax=docker/dockerfile:1
FROM debian:latest

# use sid for latest packages
# RUN echo "deb http://deb.debian.org/debian sid main" > /etc/apt/sources.list
# or use tsinghua mirror for faster download
RUN apt update && apt install -y apt-transport-https ca-certificates
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ sid main contrib non-free non-free-firmware" > /etc/apt/sources.list
# install packages
RUN apt update && apt install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    wget \
    ca-certificates \
    gnupg2 \
    curl



RUN apt install -y \
    software-properties-common # apt-add-repository \
    lsb_release

# install latest clang and clang tools
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/unstable/ llvm-toolchain main" >> /etc/apt/sources.list && \
    apt update && apt install -y \
    clang \
    clang-tidy \
    clang-format \
    clangd \
    lldb


# install latest cmake (It's not the latest version)
# TODO update it
RUN apt install -y cmake

# install other tools [optional]
RUN apt install -y \
    tmux \
    neovim \
    openssh-server \
    gdb \
    gdbserver \
    valgrind \
    strace \
    ltrace \
    openssh-client \
    rsync \
    htop


# create dir
RUN mkdir -p /root/app
WORKDIR /root/app

# install vcpkg from my script.
RUN apt-get install curl zip unzip tar -y
RUN  git clone https://github.com/Microsoft/vcpkg.git
RUN ./vcpkg/bootstrap-vcpkg.sh
RUN mkdir -p ~/bin && ln -s ~/app/vcpkg/vcpkg ~/bin/vcpkg

# add vcpkg to PATH
ENV PATH="/root/bin:${PATH}"

# export vcpkg env.
RUN echo "export EDITOR=vim" >> ~/.bashrc
RUN echo "export CMAKE_TOOLCHAIN_FILE=~/app/vcpkg/scripts/buildsystems/vcpkg.cmake" >> ~/.bashrc

# export cmake env.
RUN echo "export CMAKE_GENERATOR='Ninja'" >> ~/.bashrc