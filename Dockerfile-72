FROM behance/docker-nginx:8.5
MAINTAINER Bryan Latten <latten@adobe.com>

# Set TERM to suppress warning messages.
ENV CONF_PHPFPM=/etc/php/7.2/fpm/php-fpm.conf \
    CONF_PHPMODS=/etc/php/7.2/mods-available \
    CONF_FPMPOOL=/etc/php/7.2/fpm/pool.d/www.conf \
    CONF_FPMOVERRIDES=/etc/php/7.2/fpm/conf.d/overrides.user.ini \
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

# - Update security packages, only
RUN /bin/bash -e /security_updates.sh && \
    apt-get install -yqq --no-install-recommends \
        gpg-agent \
        git \
        curl \
        wget \
        software-properties-common \
        locales \
    && \
    locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && \
    add-apt-repository ppa:ondrej/php -y && \
    echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list && \
    wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
    # Prevent newrelic install from prompting for input \
    echo newrelic-php5 newrelic-php5/application-name string "REPLACE_NEWRELIC_APP" | debconf-set-selections && \
    echo newrelic-php5 newrelic-php5/license-key string "REPLACE_NEWRELIC_LICENSE" | debconf-set-selections && \
    # Perform cleanup \
    apt-get remove --purge -yq \
        patch \
        software-properties-common \
        locales \
        wget \
    && \
    /bin/bash /clean.sh

# TODO: fix these packages:
# php7.2-mcrypt

# Add PHP and support packages \
RUN apt-get update -q && \
    # Ensure PHP 5.5 + 5.6 + 7.1 don't accidentally get added by PPA
    apt-mark hold \
            php5.6-cli \
            php5.6-common \
            php5.6-json \
            php7.0-cli \
            php7.0-common \
            php7.0-json \
            php7.1-cli \
            php7.1-common \
            php7.1-json \
            php7.3-cli \
            php7.3-common \
            php7.3-json \
    && \
    apt-get -yqq install \
        php7.2 \
        php7.2-apcu \
        php7.2-bcmath \
        php7.2-bz2 \
        php7.2-curl \
        php7.2-dev \
        php7.2-fpm \
        php7.2-gd \
        php7.2-igbinary \
        php7.2-intl \
        php7.2-json \
        php7.2-mbstring \
        php7.2-memcache \
        php7.2-memcached \
        php7.2-msgpack \
        php7.2-mysql \
        php7.2-pgsql \
        php7.2-xml \
        php7.2-yaml \
        php7.2-zip \
        php-xdebug \
        newrelic-php5 \
        newrelic-php5-common \
        newrelic-daemon \
    && \
    phpdismod pdo_pgsql && \
    phpdismod pgsql && \
    phpdismod yaml && \
    phpdismod xdebug && \
    # Remove extra extensions installed via packages for other versions of PHP, leaving the active engine folder
    rm -rf /usr/lib/php/20121212 && \
    rm -rf /usr/lib/php/20131226 && \
    rm -rf /usr/lib/php/20151012 && \
    rm -rf /usr/lib/php/20160303 && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    # Install new PHP 7.X-stable version of Redis
    pecl install redis-4.2.0 && \
    echo "extension=redis.so" > $CONF_PHPMODS/redis.ini && \
    # Remove dev packages that were only in place just to compile extensions
    apt-get remove --purge -yq \
        php7.2-dev \
    && \
    /bin/bash /clean.sh

# Overlay the root filesystem from this repo
COPY ./container/root /

# - Make additional hacks to migrate files/config from 7.0 --> 7.2 folder
RUN cp /etc/php/7.0/mods-available/* $CONF_PHPMODS && \
    cp /etc/php/7.0/fpm/conf.d/overrides.user.ini $CONF_FPMOVERRIDES && \
    # Hack: share startup scripts between variant versions by symlinking \
    ln -s /usr/sbin/php-fpm7.2 /usr/sbin/php-fpm && \
    # Override default ini values for both CLI + FPM \
    phpenmod overrides && \
    # Enable NewRelic via Ubuntu symlinks, but disable in file. Cross-variant startup script uncomments with env vars.
    phpenmod newrelic && \
    # - Run standard set of tweaks to ensure runs performant, reliably, and consistent between variants
    /bin/bash -e /prep-php.sh

RUN goss -g /tests/php-fpm/7.2.goss.yaml validate && \
    /aufs_hack.sh
