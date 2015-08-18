FROM behance/docker-nginx:1.1.0
MAINTAINER Bryan Latten <latten@adobe.com>

# Install singularity_runner
RUN apt-get install build-essential ruby1.9.1-dev -y && \
    gem install --no-rdoc --no-ri singularity_dsl --version 1.6.3

RUN locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && \
    add-apt-repository ppa:git-core/ppa -y && \
    add-apt-repository ppa:ondrej/php5-5.6 -y && \
    apt-get update -yq && \
    apt-get install -yq git

# Update package cache with new PPA, install language and modules
RUN apt-get update && \
    apt-get -yq install \
        php5=5.6.12+dfsg-1+deb.sury.org~trusty+1 \
        php5-fpm=5.6.12+dfsg-1+deb.sury.org~trusty+1 \
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
        nano && \
    php5dismod xdebug

RUN pecl install igbinary-1.2.1 && \
    echo 'extension=igbinary.so' > /etc/php5/mods-available/igbinary.ini && \
    php5enmod igbinary

RUN printf "\n" | pecl install apcu-4.0.7 && \
    echo 'extension=apcu.so' > /etc/php5/mods-available/apcu.ini && \
    php5enmod apcu


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
