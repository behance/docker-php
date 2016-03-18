#!/bin/bash

# Ensure that worker entrypoint does not also run nginx processes
if [ $CONTAINER_ROLE == 'web' ]
then
  echo '[run] enabling php-fpm'

  # Enable php-fpm as a supervised service
  ln -s /etc/services-available/php-fpm /etc/services.d/php-fpm
fi
