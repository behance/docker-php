#!/bin/bash

if [[ $PHP_FPM_LOG_LIMIT ]]
then
  echo "[php-fpm] setting log_limit ${PHP_FPM_LOG_LIMIT} (PHP 7.3+ only)"
  sed -i "s/;log_limit.*/log_limit = ${PHP_FPM_LOG_LIMIT}/" $CONF_PHPFPM
fi

if [[ $PHP_FPM_LOG_BUFFERING ]]
then
  # Experimental, eventually disable to maximize performance in heavy logging scenarios
  echo "[php-fpm] setting log_buffering ${PHP_FPM_LOG_BUFFERING} (PHP 7.3+ only)"
  sed -i "s/;log_buffering.*/log_buffering = ${PHP_FPM_LOG_BUFFERING}/" $CONF_PHPFPM
fi
