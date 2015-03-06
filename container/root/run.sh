#!/bin/bash

if [[ -f /root/.composer/config.json ]]
then
  echo "Running `composer install`"
  singularity_runner test
else
  echo "Starting apache2"
  source /etc/apache2/envvars
  exec apache2 -D FOREGROUND
fi
