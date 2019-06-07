#!/usr/bin/with-contenv bash

# Validate that env config overrides are acceptable to php-fpm
php-fpm -t &> /dev/null

if [ $? != 0 ]; then
  echo "[fpm-validation] Config validation failed, cannot start..."
  php-fpm -t
fi
