FROM ubuntu:22.04

ENV BINUTILS_RELEASE="2.34" \
    GCC_RELEASE="9.3.0" \
    MAKE_DIR="/cross" \
    MAKE_OPTS="-j4"

RUN apt-get update && \
    apt-get install -y autoconf bison build-essential flex gettext git lhasa libgmp-dev libmpc-dev \
                       libmpfr-dev ncurses-dev python3-pip rsync texinfo wget zip zopfli && \
    python3 -m pip install --user -U pip setuptools && \
    python3 -m pip install --user crcmod cython && \
    python3 -m pip install --user -U git+https://github.com/cnvogelg/amitools.git

RUN git config --global pull.rebase false && \
    export MAKE_DIR && \
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
