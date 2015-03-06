#!/bin/bash

if [[ -d /root/.composer ]]
then
  echo "Running `composer install`"
  composer install
else
  echo "Starting apache2"
  source /etc/apache2/envvars
  exec apache2 -D FOREGROUND
fi
