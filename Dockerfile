
# main image
FROM ubuntu:22.04 as dev

ENV DEBIAN_FRONTEND noninteractive
ENV CCACHE_DIR=/ccache
ENV CCACHE_MAXSIZE=25G

RUN sed -i "s/^# deb-src/deb-src/g" /etc/apt/sources.list

RUN apt update -y && yes | unminimize
RUN \
    apt update -y && apt install -y \
    build-essential git cmake binutils-gold gosu sudo valgrind python3-pip \
    bison flex \
    llvm clang \
    zsh powerline fonts-powerline \
    iputils-ping iproute2 ripgrep \
    libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev \
    ccache locales rr htop strace ltrace tree nasm neovim bear \
    lsb-release ubuntu-dbgsym-keyring texinfo \
    lsb-release ubuntu-dbgsym-keyring gcc-multilib \
    linux-tools-generic \
    wget curl ninja-build xdot libgmp-dev tmux \
    man psmisc lsof rsync zip unzip qpdf ncdu fdupes parallel \
    texlive texlive-latex-extra texlive-fonts-recommended dvipng cm-super \
    g++ libz3-dev zlib1g-dev libc++-dev mercurial nano

# install python packages
RUN sudo pip3 install mypy pylint matplotlib lit pyyaml

RUN locale-gen en_US.UTF-8

# these are overwritten with the ones of the user building this
ARG USER_UID=1000
ARG USER_GID=1000

#Enable sudo group
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /tmp

RUN update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

#Create user "user"
RUN groupadd -g ${USER_GID} user
# -l -> https://github.com/moby/moby/issues/5419
RUN useradd -l --shell /bin/bash -c "" -m -u ${USER_UID} -g user -G sudo user
WORKDIR "/home/user"

USER user
RUN wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py \
  && echo source ~/.gdbinit-gef.py >> ~/.gdbinit

# Install Rust
RUN curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | bash -s -- -y --default-toolchain nightly-2023-03-22
ENV PATH="/home/user/.cargo/bin:${PATH}"

RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -- \
    -t agnoster

COPY env/check_env.sh /usr/bin/
USER user
