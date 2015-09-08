FROM behance/docker-nginx:1.2.1
MAINTAINER Bryan Latten <latten@adobe.com>

# Install pre-reqs for the next steps
RUN apt-get update && apt-get -yq install \
        build-essential \
        wget

# Ensure additional software sources are configured, and prevents newrelic install from prompting for input
RUN locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && \
    add-apt-repository ppa:git-core/ppa -y && \
    add-apt-repository ppa:ondrej/php5-5.6 -y && \
    echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | sudo tee /etc/apt/sources.list.d/newrelic.list && \
    wget -O- https://download.newrelic.com/548C16BF.gpg | sudo apt-key add - && \
    echo newrelic-php5 newrelic-php5/application-name string "REPLACE_NEWRELIC_APP" | debconf-set-selections && \
    echo newrelic-php5 newrelic-php5/license-key string "REPLACE_NEWRELIC_LICENSE" | debconf-set-selections;

# Update package cache with new PPA, install language and modules
RUN apt-get update && \
    apt-get -yq install \
        php5=5.6.13+dfsg-1+deb.sury.org~trusty+3 \
        php5-fpm=5.6.13+dfsg-1+deb.sury.org~trusty+3 \
        php5-gearman=1.1.2-1+deb.sury.org~trusty+2 \
        php5-memcache=3.0.8-5+deb.sury.org~trusty+1 \
        php5-memcached=2.2.0-2+deb.sury.org~trusty+1 \
        php5-dev \
        php5-gd \
        php5-mysqlnd \
        php5-intl \
        php5-curl \
        php5-mcrypt \
        php5-json \
        php5-xdebug \
        newrelic-php5 \
        wget \
        git \
        && \
    php5dismod xdebug && \
    php5dismod newrelic

# Build/install any extensions that aren't in trouble-free packaging
RUN pecl install igbinary-1.2.1 && \
    echo 'extension=igbinary.so' > /etc/php5/mods-available/igbinary.ini && \
    php5enmod igbinary && \
    printf "\n" | pecl install apcu-4.0.7 && \
    echo 'extension=apcu.so' > /etc/php5/mods-available/apcu.ini && \
    php5enmod apcu

# Prevent newrelic daemon from auto-spawning; uses newrelic run.d script to enable at runtime, when ENV variables are present
# @see https://docs.newrelic.com/docs/agents/php-agent/advanced-installation/starting-php-daemon-advanced
RUN sed -i "s/;newrelic.daemon.dont_launch = 0/newrelic.daemon.dont_launch = 3/" /etc/php5/mods-available/newrelic.ini

# Perform cleanup, ensure unnecessary packages are removed
RUN apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*

# Overlay the root filesystem from this repo
COPY ./container/root /

#####################################################################

# Move downstream application to final resting place
ONBUILD COPY ./ /app/

#####################################################################


# Packages in this parent container are provided for ease of integration
# in downstream (child) builds. Some dev-only packages need to be removed
# for a production system (git/wget/gcc/etc)

# TODO: script needs to be called AFTER downstream build is performed,
#   ONBUILD instruction gets called BEFORE, so not useful
# RUN /bin/bash /clean.sh



EXPOSE 80
CMD ["/bin/bash", "/run.sh"]
