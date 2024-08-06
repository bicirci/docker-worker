# syntax=docker/dockerfile:1

FROM registry.cn-beijing.aliyuncs.com/9zyun/ubuntu:18.04

LABEL maintainer="Anaconda, Inc"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        git \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1 \
        mercurial \
        openssh-client \
        procps \
        subversion \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH

CMD [ "/bin/bash" ]

# Leave these args here to better use the Docker build cache
# renovate: datasource=custom.miniconda_installer
ARG INSTALLER_URL_LINUX64="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.5.0-0-Linux-x86_64.sh"
ARG SHA256SUM_LINUX64="4b3b3b1b99215e85fd73fb2c2d7ebf318ac942a457072de62d885056556eb83e"
# renovate: datasource=custom.miniconda_installer
ARG INSTALLER_URL_S390X="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.5.0-0-Linux-s390x.sh"
ARG SHA256SUM_S390X="bd2a0a8ea34c84c860868d5b8efde07afc51cdede76b64dd94e9c3fd2d65257e"
# renovate: datasource=custom.miniconda_installer
ARG INSTALLER_URL_AARCH64="https://repo.anaconda.com/miniconda/Miniconda3-py312_24.5.0-0-Linux-aarch64.sh"
ARG SHA256SUM_AARCH64="70afe954cc8ee91f605f9aa48985bfe01ecfc10751339e8245eac7262b01298d"

RUN set -x && \
    UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
        INSTALLER_URL="${INSTALLER_URL_LINUX64}"; \
        SHA256SUM="${SHA256SUM_LINUX64}"; \
    elif [ "${UNAME_M}" = "s390x" ]; then \
        INSTALLER_URL="${INSTALLER_URL_S390X}"; \
        SHA256SUM="${SHA256SUM_S390X}"; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
        INSTALLER_URL="${INSTALLER_URL_AARCH64}"; \
        SHA256SUM="${SHA256SUM_AARCH64}"; \
    fi && \
    wget "${INSTALLER_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    sha256sum --check --status shasum && \
    mkdir -p /opt && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# --no-install-recommends
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    build-essential crossbuild-essential-arm64 bash-completion\
	repo git ssh vim sudo locales time rsync bc 7zip ca-certificates\
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

