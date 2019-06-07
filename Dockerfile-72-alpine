FROM behance/docker-nginx:8.5-alpine
MAINTAINER Bryan Latten <latten@adobe.com>

# Set TERM to suppress warning messages.
ENV CONF_PHPFPM=/etc/php7/php-fpm.conf \
    CONF_PHPMODS=/etc/php7/conf.d \
    CONF_FPMPOOL=/etc/php7/php-fpm.d/www.conf \
    CONF_FPMOVERRIDES=/etc/php/7.0/fpm/conf.d/overrides.user.ini \
    APP_ROOT=/app \
    SERVER_WORKER_CONNECTIONS=3072 \
    SERVER_CLIENT_BODY_BUFFER_SIZE=128k \
    SERVER_CLIENT_HEADER_BUFFER_SIZE=1k \
    SERVER_CLIENT_BODY_BUFFER_SIZE=128k \
    SERVER_LARGE_CLIENT_HEADER_BUFFERS="4 256k" \
    PHP_FPM_MAX_CHILDREN=4096 \
    PHP_FPM_START_SERVERS=20 \
    PHP_FPM_MAX_REQUESTS=1024 \
    PHP_FPM_MIN_SPARE_SERVERS=5 \
    PHP_FPM_MAX_SPARE_SERVERS=128 \
    PHP_FPM_MEMORY_LIMIT=256M \
    PHP_FPM_MAX_EXECUTION_TIME=60 \
    PHP_FPM_UPLOAD_MAX_FILESIZE=1M \
    PHP_OPCACHE_MEMORY_CONSUMPTION=128 \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER=16 \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE=5 \
    CFG_APP_DEBUG=1

RUN apk update && \
    apk add --no-cache \
      git \
      curl \
      wget \
      php7 \
      php7-bcmath \
      php7-bz2 \
      php7-fpm \
      php7-apcu \
      php7-calendar \
      php7-common \
      php7-ctype \
      php7-curl \
      php7-dom \
      php7-exif \
      php7-ftp \
      php7-gd \
      php7-gettext \
      php7-iconv \
      php7-intl \
      php7-json \
      php7-mcrypt \
      php7-mbstring \
      # php7-msgpack@edge \
      # php7-memcached@community \
      php7-mysqli \
      php7-mysqlnd \
      php7-opcache \
      php7-openssl \
      php7-pdo_pgsql \
      php7-pgsql \
      php7-pcntl \
      php7-pdo \
      php7-pdo_mysql \
      php7-phar \
      php7-posix \
      php7-session \
      php7-simplexml \
      php7-sockets \
      php7-sysvmsg \
      php7-sysvsem \
      php7-sysvshm \
      php7-shmop \
      php7-tokenizer \
      php7-xdebug \
      php7-xml \
      php7-xmlreader \
      php7-xmlwriter \
      php7-xsl \
      php7-zip \
      php7-zlib \
    && \
    # Disable xdebug by default \
    sed -i 's/zend_extension\s\?=/;zend_extension =/' $CONF_PHPMODS/xdebug.ini && \
    # Disable postgres by default \
    sed -i 's/extension/;extension/' $CONF_PHPMODS/01_pdo_pgsql.ini && \
    sed -i 's/extension/;extension/' $CONF_PHPMODS/00_pgsql.ini && \
    /bin/bash -e /clean.sh

# Locate and install latest Alpine-compatible NewRelic, seed with variables to be replaced
# Requires PHP to already be installed
RUN NEWRELIC_MUSL_PATH=$(curl -s https://download.newrelic.com/php_agent/release/ | grep 'linux-musl.tar.gz' | cut -d '"' -f2) && \
    NEWRELIC_PATH="https://download.newrelic.com${NEWRELIC_MUSL_PATH}" && \
    curl -L ${NEWRELIC_PATH} -o ./root/newrelic-musl.tar.gz && \
    cd /root && \
    gzip -dc newrelic-musl.tar.gz | tar xf - && \
    rm newrelic-musl.tar.gz && \
    NEWRELIC_DIRECTORY=/root/$(basename $(find . -maxdepth 1 -type d -name newrelic\*)) && \
    cd $NEWRELIC_DIRECTORY && \
    echo "\n" | ./newrelic-install install && \
    chown root:root $NEWRELIC_DIRECTORY/agent/x64/newrelic-20160303.so && \
    mv $NEWRELIC_DIRECTORY/agent/x64/newrelic-20160303.so /usr/lib/php7/modules/newrelic.so && \
    rm -rf $NEWRELIC_DIRECTORY/agent/x64 && \
    # Fix permissions on extracted folder \
    chown -R $NOT_ROOT_USER:$NOT_ROOT_USER * && \
    /bin/bash -e /clean.sh

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

RUN apk update && \
    apk add --no-cache \
        yaml-dev \
        zlib-dev \
        libmemcached-dev \
        cyrus-sasl-dev \
    && \
    apk add --no-cache --virtual .phpize_deps \
        autoconf file g++ gcc libc-dev make pkgconf re2c php7-dev php7-pear \
    && \
    sed -i 's/^exec $PHP -C -n/exec $PHP -C/g' $(which pecl) && \
    pecl install igbinary-3.0.1 && \
    echo "extension=igbinary.so" > $CONF_PHPMODS/igbinary.ini && \
    pecl install yaml-2.0.4 && \
    echo ";extension=yaml.so" > $CONF_PHPMODS/yaml.ini && \
    pecl install redis-4.2.0 && \
    echo ";extension=redis.so" > $CONF_PHPMODS/redis.ini && \
    pecl install msgpack-2.0.3 && \
    echo "extension=msgpack.so" > $CONF_PHPMODS/msgpack.ini && \
    pecl install memcached-3.1.3 && \
    echo "extension=memcached.so" > $CONF_PHPMODS/memcached.ini && \
    rm -rf /usr/share/php7 && \
    apk del .phpize_deps && \
    /bin/bash -e /clean.sh

# Overlay the root filesystem from this repo
COPY ./container/root /

# - Make additional hacks to migrate files from Ubuntu to Alpine folder structure
RUN cp /etc/php/7.0/mods-available/* $CONF_PHPMODS && \
    rm $CONF_PHPMODS/00_opcache.ini && \
    # - Run standard set of tweaks to ensure runs performant, reliably, and consistent between variants
    touch /var/run/lock && \
    chown $NOT_ROOT_USER:$NOT_ROOT_USER /var/log/php7 && \
    ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm && \
    /bin/bash -e prep-php.sh

RUN goss -g /tests/php-fpm/7.2-alpine.goss.yaml validate && \
    /aufs_hack.sh
