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

  # php-fpm performance tuning
  # Set open file descriptor rlimit for the master php-fpm process.
  if [[ $CONF_FPM_LIMIT_FILES ]]
  then
    echo "[php-fpm-performance] setting rlimit_files ${CONF_FPM_LIMIT_FILES}"
    sed -i "s/^;rlimit_files =.*/rlimit_files=${CONF_FPM_LIMIT_FILES}/" $CONF_FPMPOOL
  fi

  # Set max core size rlimit for the master process.
  # Possible Values: 'unlimited' or an integer greater or equal to 0
  if [[ $CONF_FPM_LIMIT_CORE ]]
  then
    echo "[php-fpm-performance] setting rlimit_core ${CONF_FPM_LIMIT_CORE}"
    sed -i "s/^;rlimit_core = 0/rlimit_core = ${CONF_FPM_LIMIT_CORE}/" $CONF_FPMPOOL
  fi

else
  echo '[run] non-web mode, bypassing FPM startup'
fi
