FROM behance/docker-nginx:5.0
MAINTAINER Bryan Latten <latten@adobe.com>

# Set TERM to suppress warning messages.
ENV CONF_PHPFPM=/etc/php/7.0/fpm/php-fpm.conf \
    CONF_PHPMODS=/etc/php/7.0/mods-available \
    CONF_FPMPOOL=/etc/php/7.0/fpm/pool.d/www.conf \
    CONF_FPMOVERRIDES=/etc/php/7.0/fpm/conf.d/overrides.user.ini \
    APP_ROOT=/app

# Ensure the latest base packages are up to date (don't require a parent rebuild)
RUN apt-get update -q && \
    apt-get upgrade -yqq && \
    apt-get install -yqq \
        git \
        curl \
        wget \
        curl \
        software-properties-common \
    && \
    locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && \
    add-apt-repository ppa:git-core/ppa -y && \
    add-apt-repository ppa:ondrej/php -y && \
    echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | sudo tee /etc/apt/sources.list.d/newrelic.list && \
    wget -O- https://download.newrelic.com/548C16BF.gpg | sudo apt-key add - && \
    # Prevent newrelic install from prompting for input \
    echo newrelic-php5 newrelic-php5/application-name string "REPLACE_NEWRELIC_APP" | debconf-set-selections && \
    echo newrelic-php5 newrelic-php5/license-key string "REPLACE_NEWRELIC_LICENSE" | debconf-set-selections && \
    apt-get remove --purge -yq \
        software-properties-common \
    && \
    rm -rf /var/lib/apt/lists/*

# Ensure cleanup script is available for the next command
ADD ./container/root/clean.sh /clean.sh

# Add PHP and support packages \
RUN apt-get update -q && \
    apt-get -yqq install \
        php7.0 \
        php7.0-fpm \
        php7.0-mysql \
        php7.0-xml \
        php7.0-curl \
        php7.0-gd \
        php7.0-intl \
        php7.0-json \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-pgsql \
        php7.0-zip \
        php-apcu \
        php-gearman \
        php-igbinary \
        php-memcache \
        php-memcached \
        php-xdebug \
        newrelic-php5 \
    && \
    phpdismod newrelic && \
    phpdismod pdo_pgsql && \
    phpdismod pgsql && \
    phpdismod xdebug && \
    # Add Guzzle feature flag to newrelic APM \
    echo "newrelic.feature_flag = guzzle" >> $CONF_PHPMODS/newrelic.ini && \
    # Ensure development/compile libs are removed \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    /bin/bash /clean.sh

# - Configure php-fpm to use TCP rather than unix socket (for stability), fastcgi_pass is also set by /etc/nginx/sites-available/default
# - Set base directory for all php (/app), difficult to use APP_PATH as a replacement, otherwise / breaks command
# - Baseline "optimizations" before benchmarking succeeded at concurrency of 150
# @see http://www.codestance.com/tutorials-archive/install-and-configure-php-fpm-on-nginx-385
# - Ensure environment variables aren't cleaned, will make it into FPM  workers
# - php-fpm processes must pick up stdout/stderr from workers, will cause minor performance decrease (but is required)
# - Disable systemd integration, it is not present nor responsible for running service
# - Enforce ACL that only 127.0.0.1 may connect
# - Allow FPM to pick up extra configuration in fpm/conf.d folder

# TODO: allow ENV specification of performance management at runtime (in run.d startup script)

RUN sed -i "s/listen = .*/listen = 127.0.0.1:9000/" $CONF_FPMPOOL && \
    sed -i "s/;chdir = .*/chdir = \/app/" $CONF_FPMPOOL && \
    sed -i "s/pm.max_children = .*/pm.max_children = 4096/" $CONF_FPMPOOL && \
    sed -i "s/pm.start_servers = .*/pm.start_servers = 20/" $CONF_FPMPOOL && \
    sed -i "s/;pm.max_requests = .*/pm.max_requests = 1024/" $CONF_FPMPOOL && \
    sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = 5/" $CONF_FPMPOOL && \
    sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = 128/" $CONF_FPMPOOL && \
    sed -i "s/;clear_env/clear_env/" $CONF_FPMPOOL && \
    sed -i "s/;catch_workers_output/catch_workers_output/" $CONF_FPMPOOL && \
    sed -i "s/error_log = .*/error_log = \/dev\/stdout/" $CONF_PHPFPM && \
    sed -i "s/;listen.allowed_clients/listen.allowed_clients/" $CONF_PHPFPM && \
    # Since PHP-FPM will be run without root privileges, comment these lines to prevent any startup warnings \
    sed -i "s/^user =/;user =/" $CONF_FPMPOOL && \
    sed -i "s/^group =/;group =/" $CONF_FPMPOOL && \
    # Required for php-fpm to place .sock file into, fails otherwise \
    mkdir /var/run/php/ && \
    chown -R $NOT_ROOT_USER:$NOT_ROOT_USER /var/run/php /var/run/lock /var/log/newrelic

# Overlay the root filesystem from this repo
COPY ./container/root /

# Override default ini values for both CLI + FPM
RUN phpenmod overrides && \
    # Set nginx to listen on defined port \
    sed -i "s/listen [0-9]*;/listen ${CONTAINER_PORT};/" $CONF_NGINX_SITE
