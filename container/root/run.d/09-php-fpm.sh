#!/bin/bash

# Ensure that worker entrypoint does not also run nginx processes
if [ $CONTAINER_ROLE == 'web' ]
then

  echo '[run] enabling php-fpm'

  # Enable php-fpm as a supervised service
  if [ -d /etc/services.d/php-fpm ]
  then
    echo '[run] php-fpm already enabled'
  else
    ln -s /etc/services-available/php-fpm /etc/services.d/php-fpm
  fi

fi
