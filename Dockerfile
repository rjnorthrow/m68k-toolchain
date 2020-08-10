FROM ubuntu:20.04

ENV BINUTILS_RELEASE=2.28 \
    GCC_RELEASE=7.1.0 \
    MAKE_DIR=/cross \
    MAKE_OPTS="-j4" \
    TIME_ZONE="Europe/London"

RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    ln -fs /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y autoconf bison build-essential flex gettext git lhasa \
        libgmp-dev libmpc-dev libmpfr-dev ncurses-dev rsync texinfo wget && \
    mkdir -p ${MAKE_DIR}/bin && \
    export PATH=$PATH:${MAKE_DIR}/bin && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_RELEASE}.tar.bz2 && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_RELEASE}/gcc-${GCC_RELEASE}.tar.bz2 && \
    wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz && \
    wget http://sun.hasenbraten.de/vlink/release/vlink.tar.gz && \
    tar xf binutils-${BINUTILS_RELEASE}.tar.bz2 && \
    tar xf gcc-${GCC_RELEASE}.tar.bz2 && \
    tar xf vasm.tar.gz && \
    tar xf vlink.tar.gz && \
    cd binutils-${BINUTILS_RELEASE} && \
    ./configure --prefix=${MAKE_DIR} --target=m68k-unknown-elf && \
    make ${MAKE_OPTS} && \
    make install && \
    cd ../gcc-${GCC_RELEASE} && \
    sed -i 's/--check/-c/g' contrib/download_prerequisites && \
    ./contrib/download_prerequisites && \
    mkdir /gcc-build && \
    cd /gcc-build && \
    ../gcc-${GCC_RELEASE}/configure --prefix=${MAKE_DIR} --target=m68k-unknown-elf --enable-languages=c --disable-libssp && \
    make ${MAKE_OPTS} && \
    make install && \
    cd ../vasm && \
    make ${MAKE_OPTS} CPU=m68k SYNTAX=mot && \
    cp vasmm68k_mot vobjdump ${MAKE_DIR}/bin/ && \
    cd ../vlink && \
    make ${MAKE_OPTS} && \
    cp vlink ${MAKE_DIR}/bin/ && \
    cd .. && \
    git clone https://github.com/bebbo/amiga-gcc.git && \
    cd amiga-gcc && \
    make update && \ 
    make all ${MAKE_OPTS} PREFIX=${MAKE_DIR} && \
    cd / && \
    rm -rf /amiga-gcc* /binutils* /gcc* /vasm* /vlink*
