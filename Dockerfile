FROM nginx:alpine-slim

ENV PHP_ETC_DIR=/etc/php81
ENV PHP_LOG_DIR=/var/log/php81
ENV NGINX_ETC_DIR=/etc/nginx
ENV NGINX_LOG_DIR=/var/log/nginx

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add curl
RUN apk add php php-fpm php-opcache
RUN apk add php-gd php-zlib php-curl
RUN apk add php-mysqli php-intl php-exif 
RUN apk add php-ldap php-bz2 php-session
RUN apk add php-dom php-simplexml php-xmlreader
RUN apk add php-fileinfo php-xmlwriter php-phar php-zip
RUN apk add php-ctype php-iconv php-sodium

COPY etc/php ${PHP_ETC_DIR}
COPY etc/nginx ${NGINX_ETC_DIR}

RUN ln -sf /dev/stdout ${NGINX_LOG_DIR}/access.log \
    && ln -sf /dev/stderr ${NGINX_LOG_DIR}/error.log \
    && ln -sf /dev/stderr ${PHP_LOG_DIR}/error.log

# Download GLPI
ENV GLPI_VERSION=10.0.10
WORKDIR /var/www/
RUN curl -sSLf https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz | tar -zx

CMD [ "/bin/bash", "-c", "php-fpm81 && chmod -R 777 /var/www/* && nginx -g 'daemon off;'" ]
