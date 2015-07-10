#!/bin/bash

if [[ -f /root/.composer/config.json ]]
then
  echo "Running `composer install`"
  composer install
else

  # Adds docker environment variables where Apache would normally eat them by
  # entering them as Virtualhost environment variables
  VARS=`env | grep ^CFG_`;
  DEST_CONF=/etc/apache2/conf-available/docker-environment.conf

  echo 'Importing Environment Variables'
  for p in $VARS
  do
    ENV='SetEnv '${p/=/ }
    echo $ENV >> $DEST_CONF
  done

  if [[ $CFG_APP_DEBUG = 1 || $CFG_APP_DEBUG = '1' || $CFG_APP_DEBUG = 'true' ]]
  then
    echo 'Opcache set to WATCH for file changes'
  else
    echo 'Opcache set to PERFORMANCE'
    echo 'opcache.revalidate_freq=0' >> /etc/php5/mods-available/opcache.ini
    echo 'opcache.validate_timestamps=0' >> /etc/php5/mods-available/opcache.ini
  fi

  echo 'Enabling Docker Config'
  a2enconf  docker-environment

  echo "Starting Apache 2"
  source /etc/apache2/envvars
  exec apache2 -D FOREGROUND

fi
