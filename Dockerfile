FROM behance/docker-nginx:2.0.2
MAINTAINER Bryan Latten <latten@adobe.com>

# Set TERM to suppress warning messages.
ENV CONF_PHPFPM=/etc/php/php-fpm.conf \
    CONF_PHPINI=/etc/php/php.ini \
    CONF_PHPMODS=/etc/php/conf.d \
    APP_ROOT=/app

# Ensure the latest base packages are leveraged
RUN apk update && \
    apk upgrade && \
    rm -rf /var/cache/apk/*

RUN apk update && \
    apk add --no-cache \
        git \
        tar \
        wget

# Add PHP and supported packages, near-feature parity with Ubuntu's PHP PPA
RUN apk update && \
    apk add --no-cache \
        'php>5.6.17' \
        php-apcu \
        php-bz2 \
        php-curl \
        php-ctype \
        php-dom \
        php-exif \
        php-fpm \
        php-gd \
        php-iconv \
        php-intl \
        php-json \
        php-mysql \
        php-mcrypt \
        'php-memcache=3.0.8-r4' \
        php-pdo_mysql \
        php-opcache \
        php-openssl \
        php-phar \
        php-pcntl \
        php-pdo \
        php-posix \
        php-sockets \
        php-shmop \
        php-sysvsem \
        php-sysvshm \
        php-sysvmsg \
        php-xml \
        php-xmlreader \
        php-zip \
        php-zlib

RUN curl -sS https://getcomposer.org/installer | php \
    && \
    mv composer.phar /usr/local/bin/composer

#         php5-gearman=1.1.2-1+deb.sury.org~trusty+2 \
#         php5-memcache=3.0.8-5+deb.sury.org~trusty+1 \
#         php5-memcached=2.2.0-2+deb.sury.org~trusty+1 \
#         php5-xdebug \

# # Build/install any extensions that aren't in trouble-free packaging
# RUN pecl install igbinary-1.2.1 && \
#     echo 'extension=igbinary.so' > /etc/php5/mods-available/igbinary.ini && \
#     php5enmod igbinary


# Install "hacked" glibc for NewRelic dependency, not normally available on Alpine
# @see https://github.com/gliderlabs/docker-alpine/issues/11#issuecomment-91329401
# RUN cd /tmp && \
#     wget -q "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
#             "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
#     apk add --no-cache --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
#     /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
#     echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

# RUN cd /tmp && \
#     wget -q https://download.newrelic.com/php_agent/release/newrelic-php5-5.4.0.150-linux.tar.gz && \
#     tar -xvf newrelic-php5-5.4.0.150-linux.tar.gz && \
#     cd newrelic-php5-5.4.0.150-linux && \
#     export NR_INSTALL_SILENT=1 && \
#     ./newrelic-install install

# @see https://docs.newrelic.com/docs/agents/php-agent/advanced-installation/starting-php-daemon-advanced
# - Prevent newrelic daemon from auto-spawning; uses newrelic run.d script to enable at runtime, when ENV variables are present
# - Configure php-fpm to use TCP rather than unix socket (for stability), fastcgi_pass is also set by /etc/nginx/sites-available/default
# - Set base directory for all php (/app), difficult to use APP_PATH as a replacement, otherwise / breaks command
# - Baseline "optimizations" before benchmarking succeeded at concurrency of 150
# @see http://www.codestance.com/tutorials-archive/install-and-configure-php-fpm-on-nginx-385
# - Ensure environment variables aren't cleaned, will make it into FPM  workers
# - php-fpm processes must pick up stdout/stderr from workers, will cause minor performance decrease (but is required)
# - Disable systemd integration, it is not present nor responsible for running service
# - Enforce ACL that only 127.0.0.1 may connect
# - Allow FPM to pick up extra configuration in fpm.d folder

# TODO: allow ENV specification of performance management at runtime (in run.d startup script)

RUN sed -i "s/listen = .*/listen = 127.0.0.1:9000/" $CONF_PHPFPM && \
    sed -i "s/;chdir = .*/chdir = \/app/" $CONF_PHPFPM && \
    sed -i "s/pm.max_children = .*/pm.max_children = 4096/" $CONF_PHPFPM && \
    sed -i "s/pm.start_servers = .*/pm.start_servers = 20/" $CONF_PHPFPM && \
    sed -i "s/;pm.max_requests = .*/pm.max_requests = 1024/" $CONF_PHPFPM && \
    sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = 5/" $CONF_PHPFPM && \
    sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = 128/" $CONF_PHPFPM && \
    sed -i "s/;clear_env/clear_env/" $CONF_PHPFPM && \
    sed -i "s/;catch_workers_output/catch_workers_output/" $CONF_PHPFPM && \
    sed -i "s/error_log = .*/error_log = \/dev\/stdout/" $CONF_PHPFPM
    # sed -i "s/;include=.*/include=\/etc\/php\/fpm.d/" $CONF_PHPFPM && \
    # sed -i "s/extension =/;extension =/" $CONF_PHPMODS/newrelic.ini && \
    # sed -i "s/;systemd_interval = .*/systemd_interval = 0/" $CONF_PHPFPM
    # sed -i "s/;listen.allowed_clients/listen.allowed_clients/" $CONF_PHPFPM

# # Overlay the root filesystem from this repo
COPY ./container/root /

# # Set sensible defaults
# RUN php5enmod defaults

#####################################################################

# Move downstream application to final resting place
# ONBUILD COPY ./ /app/

#####################################################################
