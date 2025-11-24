FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	wget unzip ca-certificates build-essential libssl-dev

#2025.09.1
ARG SNIFFER_COMMIT=f8fca503e8f8cb7aa39950d3b5b2692cfe6580fe

WORKDIR /usr/src

RUN wget --progress=dot:giga "https://github.com/voipmonitor/sniffer/archive/${SNIFFER_COMMIT}.zip" \
	&& unzip "${SNIFFER_COMMIT}.zip" \
	&& mv "sniffer-${SNIFFER_COMMIT}" sniffer

WORKDIR /usr/src/sniffer/tools/ssl_keylogger

RUN make -j$(nproc)


FROM scratch
COPY --from=builder /usr/src/sniffer/tools/ssl_keylogger/sslkeylog.so /
