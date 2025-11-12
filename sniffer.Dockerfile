FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	curl ca-certificates build-essential git default-libmysqlclient-dev checkinstall libvorbis-dev libpcap-dev \
    unixodbc-dev libsnappy-dev libcurl4-openssl-dev libssh-dev libjson-c-dev librrd-dev liblzo2-dev liblzma-dev \
    libglib2.0-dev libxml2-dev libzstd-dev liblz4-dev libpng-dev libgcrypt-dev libfftw3-dev libgoogle-perftools-dev \
    gnutls-dev libsrtp2-dev dpdk-dev libmpg123-dev libjpeg-dev libmp3lame-dev libb2-dev

RUN cd /usr/src \
	&& git clone https://github.com/voipmonitor/sniffer.git --depth 1 \
	&& cd sniffer \
	&& ./configure \
	&& make \
	&& make install

FROM debian:bookworm-slim AS final
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
    libblkid1 libbrotli1 libbsd0 libc6 libcairo2 libcap2 libcom-err2 libcurl4 libdatrie1 libdbi1 libdbus-1-3 \
    libelogind0 libexpat1 libffi8 libfftw3-double3 libfontconfig1 libfreetype6 libfribidi0 libgcc-s1 libgcrypt20 \
    libglib2.0-0 libgmp10 libgnutls30 libgpg-error0 libgraphite2-3 libgssapi-krb5-2 libharfbuzz0b libhogweed6 libicu72 \
    libidn2-0 libjson-c5 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.5-0 libltdl7 liblz4-1 liblzma5 \
    liblzo2-2 libmariadb3 libmd0 libmount1 libnettle8 libnghttp2-14 libodbc2 libogg0 libp11-kit0 libpango-1.0-0 \
    libpangocairo-1.0-0 libpangoft2-1.0-0 libpcap0.8 libpcre2-8-0 libpixman-1-0 libpng16-16 libpsl5 librrd8 librtmp1 \
    libsasl2-2 libselinux1 libsnappy1v5 libssh2-1 libssl3 libtasn1-6 libtcmalloc-minimal4 libthai0 libunistring2 \
    libvorbis0a libvorbisenc2 libx11-6 libxau6 libxcb-render0 libxcb-shm0 libxcb1 libxdmcp6 libxext6 libxml2 \
    libxrender1 libzstd1 zlib1g libmp3lame0 libmpg123-0 libjpeg62-turbo librte-ethdev23 librte-mbuf23 librte-mempool23 \
    librte-ring23 librte-eal23 libsrtp2-1 rrdtool

COPY --from=builder /usr/local/sbin/voipmonitor /usr/local/sbin/voipmonitor
COPY --from=builder /usr/src/sniffer/config/voipmonitor.conf /etc/voipmonitor/voipmonitor.conf

ENTRYPOINT ["/usr/local/sbin/voipmonitor", "--config-file=/etc/voipmonitor/voipmonitor.conf", "-k"]
