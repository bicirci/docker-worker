# syntax=docker/dockerfile:1

FROM registry.cn-beijing.aliyuncs.com/9zyun/ubuntu:18.04

RUN cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
RUN sed -i 's@http://.*ubuntu.com@http://repo.huaweicloud.com@g' /etc/apt/sources.list

# --no-install-recommends
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    build-essential crossbuild-essential-arm64 bash-completion\
	repo git ssh vim sudo locales time rsync bc p7zip-full p7zip-rar ca-certificates\
    python python-pip python-pyelftools

RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    libssl-dev liblz4-tool lib32stdc++6 unzip device-tree-compiler ncurses-dev \
	expect patchelf chrpath gawk texinfo diffstat binfmt-support \
	qemu-user-static live-build bison flex fakeroot cmake \
	subversion asciidoc w3m dblatex graphviz python-matplotlib cpio \
	libparse-yapp-perl default-jre patchutils swig expect-dev u-boot-tools

RUN update-ca-certificates

RUN locale-gen --no-purge en_US.UTF-8

RUN useradd -rm -d /home/me -s /bin/bash -g root -G sudo -u 1000 me --no-log-init
RUN echo 'me:me' | chpasswd

USER me

ENV BR2_DL_DIR=/home/me/workspace/downloads
WORKDIR /home/me

