# use Alpine Linux as the base image
FROM alpine:latest

# set working directory
WORKDIR /app

# install build dependencies
RUN apk --no-cache add \
    build-base \
    automake \
    autoconf \
    libtool \
    pkgconfig \
    curl-dev \
    libevent-dev \
    libmicrohttpd-dev \
    uthash-dev \
    jansson-dev \
    libcurl \
    git

# clone BFGMiner repository
RUN git clone --branch bfgminer --single-branch https://github.com/luke-jr/bfgminer.git .
RUN sed -i 's/git:/https:/g' .gitmodules

# build BFGMiner
RUN ./autogen.sh && \
    ./configure --enable-cpumining --enable-scrypt --enable-opencl && \
    make && \
    make install

# clean up unnecessary build dependencies
RUN apk del \
    build-base \
    automake \
    autoconf \
    libtool \
    pkgconfig \
    curl-dev \
    uthash-dev \
    git