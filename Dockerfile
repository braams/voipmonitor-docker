FROM alpine:3.22 AS downloader
RUN apk add --no-cache wget

ARG RELEASE="2025.09"
ARG VERSION="2025.09.1"

RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCH=arm64; else ARCH=armv6k; fi && \
	URL="http://sourceforge.net/projects/voipmonitor/files/${RELEASE}/voipmonitor-${ARCH}-${VERSION}-static.tar.gz/download" && \
	echo "Downloading ${URL}" && \
	wget --progress=dot:giga "${URL}" -O /voipmonitor-sniffer.tar.gz && \
	tar xzfv voipmonitor-sniffer.tar.gz --strip-components=1


FROM alpine:3.22 AS final

COPY --from=downloader /usr/local/sbin/voipmonitor /usr/local/sbin/
COPY --from=downloader /etc/voipmonitor.conf /etc/voipmonitor/voipmonitor.conf

ENTRYPOINT ["/usr/local/sbin/voipmonitor", "--config-file=/etc/voipmonitor/voipmonitor.conf", "-k"]
