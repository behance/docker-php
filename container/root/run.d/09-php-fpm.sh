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

  # HACK: symlink only leveraged by Alpine (where folder exists)
  # For web services, add FPM-specific overrides to the conf folder
  if [ ! -f /etc/php7/conf.d/overrides.user.ini ] && [ -d /etc/php7/conf.d ]
  then
    echo '[run] adding FPM-specific overrides: Alpine-only'
    ln -s $CONF_FPMOVERRIDES /etc/php7/conf.d/overrides.user.ini
  fi
else
  echo '[run] non-web mode, bypassing FPM startup'
fi
