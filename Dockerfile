FROM alpine:latest

ENV BINUTILS_RELEASE=2.35 \
    GCC_RELEASE=9.3.0 \
    MAKE_OPTS=-j4

RUN apk add --no-cache --update build-base && \
    mkdir -p /cross/bin && \
    export PATH=$PATH:/cross/bin && \
    wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_RELEASE}.tar.xz && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_RELEASE}/gcc-${GCC_RELEASE}.tar.xz && \
    wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz && \
    wget http://sun.hasenbraten.de/vlink/release/vlink.tar.gz && \
    tar xf binutils-${BINUTILS_RELEASE}.tar.xz && \
    tar xf gcc-${GCC_RELEASE}.tar.xz && \
    tar xf vasm.tar.gz && \
    tar xf vlink.tar.gz && \
    cd binutils-${BINUTILS_RELEASE} && \
    ./configure --prefix=/cross --target=m68k-unknown-elf && \
    make ${MAKE_OPTS} && \
    make install && \
    cd ../gcc-${GCC_RELEASE} && \
    sed -i 's/--check/-c/g' contrib/download_prerequisites && \
    ./contrib/download_prerequisites && \
    mkdir /gcc-build && \
    cd /gcc-build && \
    ../gcc-${GCC_RELEASE}/configure --prefix=/cross --target=m68k-unknown-elf --enable-languages=c --disable-libssp && \
    make ${MAKE_OPTS} && \
    make install && \
    cd ../vasm && \
    make ${MAKE_OPTS} CPU=m68k SYNTAX=mot && \
    cp vasmm68k_mot vobjdump /cross/bin/ && \
    cd ../vlink && \
    make ${MAKE_OPTS} && \
    cp vlink /cross/bin/ && \
    rm -rf /binutils* /gcc* /vasm* /vlink*
