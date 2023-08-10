FROM php:8.2-fpm-alpine

# Easy installer allows for easier dependency installation
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Configure PHP extensions for GLPI
RUN chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions mysqli gd intl exif ldap bz2 zip opcache

COPY ./conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

COPY ./conf.d/secure-cookie.conf /usr/local/etc/php-fpm.d/

# Download GLPI
ARG GLPI_VERSION=10.0.9
RUN curl -sSLf https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz | tar -zx
