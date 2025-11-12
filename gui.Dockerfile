FROM alpine:3.22 AS downloader

RUN apk add --no-cache wget ca-certificates

# Download ionCube loaders
RUN wget --progress=dot:giga https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O /ioncube.tar.gz \
	&& tar -xvf ioncube.tar.gz

# Download VoIPmonitor GUI
RUN wget --progress=dot:giga "https://www.voipmonitor.org/download-gui?version=latest&phpver=84&allowed" -O /voipmonitor-gui.tar.gz \
	&& mkdir /voipmonitor-gui \
	&& tar -xvf /voipmonitor-gui.tar.gz -C /voipmonitor-gui --strip-components=1

# Download required binaries to speedup the installation process

RUN wget --progress=dot:giga https://sourceforge.net/projects/voipmonitor/files/wkhtml/phantomjs-2.1.1-x86_64.gz/download -O '/phantomjs-2.1.1-x86_64.gz' \
	&& gunzip '/phantomjs-2.1.1-x86_64.gz' \
	&& chmod +x '/phantomjs-2.1.1-x86_64'

RUN wget --progress=dot:giga https://sourceforge.net/projects/voipmonitor/files/wkhtml/sox-x86_64.gz/download -O '/sox-x86_64.gz' \
	&& gunzip '/sox-x86_64.gz' \
	&& chmod +x '/sox-x86_64'

RUN wget --progress=dot:giga https://sourceforge.net/projects/voipmonitor/files/wkhtml/tshark-2.3.0.3-x86_64.gz/download -O '/tshark-2.3.0.3-x86_64.gz' \
	&& gunzip '/tshark-2.3.0.3-x86_64.gz' \
	&& chmod +x '/tshark-2.3.0.3-x86_64'

RUN wget --progress=dot:giga https://sourceforge.net/projects/voipmonitor/files/wkhtml/mergecap-2.3.0.3-x86_64.gz/download -O '/mergecap-2.3.0.3-x86_64.gz' \
	&& gunzip '/mergecap-2.3.0.3-x86_64.gz' \
	&& chmod +x '/mergecap-2.3.0.3-x86_64'

# t38_decode binary is 32-bit only
RUN wget --progress=dot:giga https://sourceforge.net/projects/voipmonitor/files/wkhtml/t38_decode-3-i686.gz/download -O '/t38_decode-3-i686.gz' \
	&& gunzip '/t38_decode-3-i686.gz' \
	&& chmod +x '/t38_decode-3-i686'


FROM debian:trixie-slim AS final

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y php php-gd php-mysql php-cli php-curl libapache2-mod-php php-mbstring php-zip tshark mtr librsvg2-bin fonts-urw-base35 rrdtool libtiff-tools wget \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=downloader /ioncube/ioncube_loader_lin_8.4.so /usr/lib/php/20240924/

RUN echo "zend_extension=ioncube_loader_lin_8.4.so" > /etc/php/8.4/mods-available/ioncube.ini \
    && echo "zend_extension=ioncube_loader_lin_8.4.so" > /etc/php/8.4/apache2/conf.d/01-ioncube.ini \
    && echo "zend_extension=ioncube_loader_lin_8.4.so" > /etc/php/8.4/cli/conf.d/01-ioncube.ini

COPY --from=downloader /voipmonitor-gui /var/www/html

COPY --from=downloader /phantomjs-2.1.1-x86_64 /var/www/html/bin/
COPY --from=downloader /sox-x86_64 /var/www/html/bin/
COPY --from=downloader /tshark-2.3.0.3-x86_64 /var/www/html/bin/
COPY --from=downloader /mergecap-2.3.0.3-x86_64 /var/www/html/bin/
COPY --from=downloader /t38_decode-3-i686 /var/www/html/bin/

COPY configuration.php /var/www/html/config/configuration.php

RUN rm /var/www/html/index.html \
    && chown -R www-data:www-data /var/www/html \
    && chmod u+w -R /var/www/html \
    && mkdir /var/spool/voipmonitor \
    && chown -R www-data:www-data /var/spool/voipmonitor

EXPOSE 80

CMD ["apache2ctl", "-DFOREGROUND"]
