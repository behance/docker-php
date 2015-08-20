#!/bin/bash

if [[ $CFG_APP_DEBUG = 1 || $CFG_APP_DEBUG = '1' || $CFG_APP_DEBUG = 'true' ]]
then

  FASTCGI_PARAM_FILE=/etc/nginx/fastcgi_params
  echo '[debug] increasing fastcgi buffer size for debug headers'
  echo "" >> $FASTCGI_PARAM_FILE
  echo "# Debug Buffer Sizes" >> $FASTCGI_PARAM_FILE
  echo "fastcgi_buffer_size 16k;" >> $FASTCGI_PARAM_FILE
  echo "fastcgi_buffers 4 16k;" >> $FASTCGI_PARAM_FILE

  echo '[debug] opcache disabled'
  php5dismod opcache

else
  echo '[debug] Opcache set to PERFORMANCE, NOT watching for file changes'
  echo 'opcache.revalidate_freq=0' >> /etc/php5/mods-available/opcache.ini
  echo 'opcache.validate_timestamps=0' >> /etc/php5/mods-available/opcache.ini
fi
