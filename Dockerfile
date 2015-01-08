FROM ubuntu:14.04
MAINTAINER Bryan Latten <latten@adobe.com>

# Move downstream application to final resting placedock
ONBUILD COPY ./ /app/

# Remove existing docroot for Apache
ONBUILD RUN rm -rf /var/www/html

# Symlink existing docroot with downstream application docroot
ONBUILD RUN ln -s /app/public /var/www/html

# Ensure package list is up to date, add tool for PPA in the next step
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install software-properties-common=0.92.37.2 -y

# IMPORTANT: PPA has UTF-8 characters in it that will fail unless locale is generated
RUN locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && add-apt-repository ppa:ondrej/php5-5.6 -y

# Update package cache with new PPA, install language and modules
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        php5=5.6.4+dfsg-1+deb.sury.org~trusty+1 \
        php5-dev=5.6.4+dfsg-1+deb.sury.org~trusty+1 \
        php5-memcache=3.0.8-4+deb.sury.org~trusty+1 \
        php5-gd=5.6.4+dfsg-1+deb.sury.org~trusty+1 \
        php5-mysqlnd=5.6.4+dfsg-1+deb.sury.org~trusty+1 \
        php5-curl=5.6.4+dfsg-1+deb.sury.org~trusty+1 \
        php5-gearman=1.1.2-1+deb.sury.org~trusty+2 \
        php5-intl=5.6.4+dfsg-1+deb.sury.org~trusty+1

RUN pecl install igbinary-1.2.1 && \
    echo 'extension=igbinary.so' > /etc/php5/mods-available/igbinary.ini && \
    php5enmod igbinary

# Enable write functionality for Apache
RUN a2enmod rewrite

# Replace apache security file with local one
COPY ./apache2/conf-available/security.conf /etc/apache2/conf-available/security.conf

# Cleanup
RUN apt-get autoclean && apt-get autoremove

ADD ./container/run.sh /run.sh
RUN chmod 755 /run.sh

EXPOSE 80
CMD ["/bin/bash", "/run.sh"]
