FROM ubuntu:24.04

ENV BINUTILS_RELEASE="2.34" \
    GCC_RELEASE="9.3.0" \
    MAKE_DIR="/cross" \
    MAKE_OPTS="-j4" \
    TIME_ZONE="Europe/London"

RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    ln -fs /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && \
    apt-get install -y apt-utils tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y autoconf bison build-essential flex gettext git lhasa libgmp-dev \
                       libmpc-dev libncurses-dev python3-venv rsync texinfo wget zip zopfli

RUN export MAKE_DIR && \
    mkdir -p $MAKE_DIR/bin && \
    export PATH=$PATH:$MAKE_DIR/bin && \
    mkdir $HOME/_tc && cd $HOME/_tc && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_RELEASE}.tar.xz && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_RELEASE}/gcc-${GCC_RELEASE}.tar.xz && \
    tar xf binutils-${BINUTILS_RELEASE}.tar.xz && \
    tar xf gcc-${GCC_RELEASE}.tar.xz && \
    cd binutils-${BINUTILS_RELEASE} && \
    ./configure --prefix=$MAKE_DIR --target=m68k-elf && \
    make ${MAKE_OPTS} && \
    make install && \
    cd ../gcc-${GCC_RELEASE} && \
    ./contrib/download_prerequisites && \
    mkdir ../gcc-build && cd ../gcc-build && \
    ../gcc-${GCC_RELEASE}/configure --prefix=$MAKE_DIR --target=m68k-elf --enable-languages=c --disable-libssp && \
    make ${MAKE_OPTS} && \
    make install && \
    cd .. && \
    git clone https://github.com/bebbo/amiga-gcc.git && \
    cd amiga-gcc && \
    make update && \
    make all ${MAKE_OPTS} PREFIX=$MAKE_DIR && \
    cd / && \
    rm -rf $HOME/_tc
