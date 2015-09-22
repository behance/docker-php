#!/bin/bash

if [[ $CFG_APP_DEBUG = 1 || $CFG_APP_DEBUG = '1' || $CFG_APP_DEBUG = 'true' ]]
then

  FASTCGI_HEADER_SIZE=16k
  FASTCGI_BUFFER_COUNT=4
  FASTCGI_BUFFER_SIZE=16k

  # IMPORTANT: avoids error "must be equal to or greater than the maximum of the value of 'proxy_buffer_size' and one of the 'proxy_buffers'"
  FASTCGI_BUSY_BUFFER=4M

  if [[ $FPM_HEADER_SIZE ]]
  then
    FASTCGI_HEADER_SIZE=$FPM_HEADER_SIZE
  fi

  if [[ $FPM_BUFFER_COUNT ]]
  then
    FASTCGI_BUFFER_COUNT=$FPM_BUFFER_COUNT
  fi

  if [[ $FPM_BUFFER_SIZE ]]
  then
    FASTCGI_BUFFER_SIZE=$FPM_BUFFER_SIZE
  fi

  if [[ $FPM_BUSY_BUFFER ]]
  then
    FASTCGI_BUSY_BUFFER=$FPM_BUSY_BUFFER
  fi

  NGINX_PARAM_FILE=/etc/nginx/sites-available/default

  echo "[debug] settings values for debug headers (headers: $FASTCGI_HEADER_SIZE; buffers: $FASTCGI_BUFFER_COUNT x $FASTCGI_BUFFER_SIZE)"
  sed -i "s/fastcgi_buffer_size \(.*\)\+;/fastcgi_buffer_size ${FASTCGI_HEADER_SIZE};/" $NGINX_PARAM_FILE
  sed -i "s/fastcgi_buffers \(.*\)\+;/fastcgi_buffers ${FASTCGI_BUFFER_COUNT} ${FASTCGI_BUFFER_SIZE};/" $NGINX_PARAM_FILE
  sed -i "s/proxy_buffer_size \(.*\)\+;/proxy_buffer_size ${FASTCGI_HEADER_SIZE};/" $NGINX_PARAM_FILE
  sed -i "s/proxy_buffers \(.*\)\+;/proxy_buffers ${FASTCGI_BUFFER_COUNT} ${FASTCGI_BUFFER_SIZE};/" $NGINX_PARAM_FILE
  sed -i "s/proxy_busy_buffers_size \(.*\)\+;/proxy_busy_buffers_size ${FASTCGI_BUSY_BUFFER};/" $NGINX_PARAM_FILE

  echo '[debug] opcache disabled'
  php5dismod opcache

else
  echo '[debug] Opcache set to PERFORMANCE, NOT watching for file changes'
  sed -i 's/;opcache.revalidate_freq/opcache.revalidate_freq/' /etc/php5/mods-available/opcache.ini
  sed -i 's/;opcache.validate_timestamps/opcache.validate_timestamps/' /etc/php5/mods-available/opcache.ini
fi
