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

  grep -q fastcgi_buffer_size $FASTCGI_PARAM_FILE

  REPLACEMENT_NEEDED=$?

  # IMPORTANT: to make this command idempotent, test for the presence of one of the keys first
  if [[ $REPLACEMENT_NEEDED == 0 ]]
  then
    echo "[debug] replacing existing buffer values"
    sed -i "s/fastcgi_buffer_size \(.*\)\+;/fastcgi_buffer_size ${FASTCGI_HEADER_SIZE};/" $FASTCGI_PARAM_FILE
    sed -i "s/fastcgi_buffers \(.*\)\+;/fastcgi_buffers ${FASTCGI_BUFFER_COUNT} ${FASTCGI_BUFFER_SIZE};/" $FASTCGI_PARAM_FILE
    sed -i "s/proxy_buffer_size \(.*\)\+;/proxy_buffer_size ${FASTCGI_HEADER_SIZE};/" $FASTCGI_PARAM_FILE
    sed -i "s/proxy_buffers \(.*\)\+;/proxy_buffers ${FASTCGI_BUFFER_COUNT} ${FASTCGI_BUFFER_SIZE};/" $FASTCGI_PARAM_FILE
  else
    echo "[debug] adding new buffer values"
    echo "" >> $FASTCGI_PARAM_FILE
    echo "fastcgi_buffer_size $FASTCGI_HEADER_SIZE;" >> $FASTCGI_PARAM_FILE
    echo "fastcgi_buffers $FASTCGI_BUFFER_COUNT $FASTCGI_BUFFER_SIZE;" >> $FASTCGI_PARAM_FILE
    echo "proxy_buffer_size $FASTCGI_HEADER_SIZE;" >> $FASTCGI_PARAM_FILE
    echo "proxy_buffers $FASTCGI_BUFFER_COUNT $FASTCGI_BUFFER_SIZE;" >> $FASTCGI_PARAM_FILE
  fi

  echo '[debug] opcache disabled'
  php5dismod opcache

else
  echo '[debug] Opcache set to PERFORMANCE, NOT watching for file changes'
  sed -i 's/;opcache.revalidate_freq/opcache.revalidate_freq/' /etc/php5/mods-available/opcache.ini
  sed -i 's/;opcache.validate_timestamps/opcache.validate_timestamps/' /etc/php5/mods-available/opcache.ini
fi
