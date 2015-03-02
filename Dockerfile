FROM ubuntu:14.04.1
MAINTAINER Bryan Latten <latten@adobe.com>

ENV DEBIAN_FRONTEND noninteractive

# Install pre-reqs, security updates
RUN apt-get update && \
    apt-get -yq install \
        openssl=1.0.1f-1ubuntu2.8 \
        ca-certificates=20141019ubuntu0.14.04.1 \
        wget

# Ensure package list is up to date, add tool for PPA in the next step
RUN apt-get update && \
    apt-get install software-properties-common=0.92.37.3 -y

# IMPORTANT: PPA has UTF-8 characters in it that will fail unless locale is generated
RUN locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && add-apt-repository ppa:ondrej/php5-5.6 -y

# Update package cache with new PPA, install language and modules
RUN apt-get update && \
    apt-get -yq install \
        php5=5.6.6+dfsg-1+deb.sury.org~trusty+1 \
        php5-dev=5.6.6+dfsg-1+deb.sury.org~trusty+1 \
        php5-gd=5.6.6+dfsg-1+deb.sury.org~trusty+1 \
        php5-mysqlnd=5.6.6+dfsg-1+deb.sury.org~trusty+1 \
        php5-intl=5.6.6+dfsg-1+deb.sury.org~trusty+1 \
        php5-curl=5.6.6+dfsg-1+deb.sury.org~trusty+1 \
        php5-gearman=1.1.2-1+deb.sury.org~trusty+2 \
        php5-memcache=3.0.8-5+deb.sury.org~trusty+1 \
        php5-xdebug=2.2.5-1+deb.sury.org~trusty+1 && \
    php5dismod xdebug

RUN pecl install igbinary-1.2.1 && \
    echo 'extension=igbinary.so' > /etc/php5/mods-available/igbinary.ini && \
    php5enmod igbinary

# Enable apache rewrite module
RUN a2enmod rewrite

# Install New Relic monitoring tools
# IMPORTANT: will not work without setting license key (nrsysmond-config --set license_key=YOUR_LICENSE_KEY)
# @see https://docs.newrelic.com/docs/release-notes/agent-release-notes/php-release-notes/php-agent-418089
#RUN sh -c 'echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list' && \
#    wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
#    apt-get update && \
#    apt-get -yq install \
#        newrelic-php5

# Perform cleanup, ensure unnecessary packages are removed
RUN apt-get -yq remove \
    gcc \
    php5-dev && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*

# Overlay the root filesystem from this repo
COPY ./container/root /

# Disable the "default" Apache site, enable the Docker one
RUN a2dissite 000-default && a2ensite 000-docker

#####################################################################

# Move downstream application to final resting place
ONBUILD COPY ./ /app/

# IMPORTANT: assumes downstream app has `public` docroot directory
ONBUILD RUN rm -rf /var/www/html && ln -s /app/public /var/www/html

#####################################################################

EXPOSE 80
CMD ["/bin/bash", "/run.sh"]
