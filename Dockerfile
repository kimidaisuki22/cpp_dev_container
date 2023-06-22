# syntax=docker/dockerfile:1
FROM debian:latest

# use sid for latest packages
# RUN echo "deb http://deb.debian.org/debian sid main" > /etc/apt/sources.list
# or use tsinghua mirror for faster download
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ sid main contrib non-free non-free-firmware" > /etc/apt/sources.list
RUN apt update && apt install -y apt-transport-https ca-certificates
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
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -

RUN    echo "deb http://apt.llvm.org/unstable/ llvm-toolchain main" >> /etc/apt/sources.list && \
    apt update 

# add proxy for apt

RUN  echo 'Acquire::http::Proxy "http://172.17.0.1:10811/";' >> /etc/apt/apt.conf.d/proxy.conf
RUN  echo 'Acquire::https::Proxy "http://172.17.0.1:10811/";' >> /etc/apt/apt.conf.d/proxy.conf


RUN apt install -y \
    clang-tidy \
    clang-format 

RUN apt install -y \
    clangd \
    lldb


RUN apt install -y \
    clang 
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

RUN echo "[http]" >> ~/.gitconfig
RUN echo "\tproxy = 172.17.0.1:10811" >> ~/.gitconfig
RUN echo "[https]" >> ~/.gitconfig
RUN echo "\tproxy = 172.17.0.1:10811" >> ~/.gitconfig
ENV  http_proxy="http://172.17.0.1:10811"        
ENV  https_proxy="http://172.17.0.1:10811"        

RUN  git clone https://github.com/Microsoft/vcpkg.git
RUN ./vcpkg/bootstrap-vcpkg.sh
RUN mkdir -p ~/bin && ln -s ~/app/vcpkg/vcpkg ~/bin/vcpkg

# add vcpkg to PATH

# export vcpkg env.
RUN echo "export EDITOR=vim" >> ~/.bashrc
RUN echo "export CMAKE_TOOLCHAIN_FILE=~/app/vcpkg/scripts/buildsystems/vcpkg.cmake" >> ~/.bashrc

# export cmake env.
RUN echo "export CMAKE_GENERATOR='Ninja'" >> ~/.bashrc

# extra tool build to libraries.
RUN apt install \
    pkg-config \
    -y

# shell custom
RUN curl -sS https://starship.rs/install.sh -o /tmp/install.sh && \
    chmod +x /tmp/install.sh && \
    /tmp/install.sh --yes && \
    rm /tmp/install.sh
RUN echo "eval \"\$(starship init bash)\"" >> ~/.bashrc

# extra envs
RUN echo 'export PATH="~/bin:${PATH}"' >> ~/.bashrc

# application custom

# funny tools

# run bash when start container by default with interactive mode
ENTRYPOINT ["/bin/bash"]
