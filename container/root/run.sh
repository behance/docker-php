#!/bin/bash

if [[ -d /root/.composer ]]
then
  composer install
else
  source /etc/apache2/envvars
  exec apache2 -D FOREGROUND
fi
