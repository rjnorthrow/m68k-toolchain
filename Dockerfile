FROM alpine

RUN apk add --no-cache build-base git python zip && \
    mkdir -p /cross/bin && \
    export PATH=$PATH:/cross/bin && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.28.tar.bz2 && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-7.1.0/gcc-7.1.0.tar.bz2 && \
    tar xf binutils-2.28.tar.bz2 && \
    tar xf gcc-7.1.0.tar.bz2 && \
    cd binutils-2.28 && \
    ./configure --prefix=/cross --target=m68k-unknown-elf && \
    make -j4 && \
    make install && \
    cd ../gcc-7.1.0 && \
    sed -i 's/--check/-c/g' contrib/download_prerequisites && \
    ./contrib/download_prerequisites && \
    mkdir /gcc-build && \
    cd /gcc-build && \
    ../gcc-7.1.0/configure --prefix=/cross --target=m68k-unknown-elf --enable-languages=c --disable-libssp && \
    make -j4 && \
    make install && \
    rm -rf /binutils* /gcc*
