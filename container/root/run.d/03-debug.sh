#!/bin/bash

if [[ $CFG_APP_DEBUG = 1 || $CFG_APP_DEBUG = '1' || $CFG_APP_DEBUG = 'true' ]]
then

  FASTCGI_HEADER_SIZE=16k
  FASTCGI_BUFFER_COUNT=4
  FASTCGI_BUFFER_SIZE=16k

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

  FASTCGI_PARAM_FILE=/etc/nginx/fastcgi_params
  echo "[debug] increasing fastcgi buffer size for debug headers (headers: $FASTCGI_HEADER_SIZE; buffers: $FASTCGI_BUFFER_COUNT x $FASTCGI_BUFFER_SIZE)"
  echo "" >> $FASTCGI_PARAM_FILE
  echo "# Debug Buffer Sizes" >> $FASTCGI_PARAM_FILE
  echo "fastcgi_buffer_size $FASTCGI_HEADER_SIZE;" >> $FASTCGI_PARAM_FILE
  echo "fastcgi_buffers $FASTCGI_BUFFER_COUNT $FASTCGI_BUFFER_SIZE;" >> $FASTCGI_PARAM_FILE
  echo "proxy_buffer_size $FASTCGI_HEADER_SIZE;" >> $FASTCGI_PARAM_FILE
  echo "proxy_buffers $FASTCGI_BUFFER_COUNT $FASTCGI_BUFFER_SIZE;" >> $FASTCGI_PARAM_FILE

  echo '[debug] opcache disabled'
  php5dismod opcache

else
  echo '[debug] Opcache set to PERFORMANCE, NOT watching for file changes'
  echo 'opcache.revalidate_freq=0' >> /etc/php5/mods-available/opcache.ini
  echo 'opcache.validate_timestamps=0' >> /etc/php5/mods-available/opcache.ini
fi
