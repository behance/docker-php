#!/bin/bash

# Validate that env config overrides are acceptable to php-fpm
php-fpm -t &> /dev/null

if [ $? == 1 ]; then
  php-fpm -t
fi
