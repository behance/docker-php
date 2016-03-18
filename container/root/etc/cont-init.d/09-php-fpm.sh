#!/usr/bin/with-contenv bash

if [[ $PHP_FPM_MEMORY_LIMIT ]]
then
  echo "[php-fpm] setting FPM memory_limit ${PHP_FPM_MEMORY_LIMIT}"
  sed -i "s/memory_limit = .*/memory_limit = ${PHP_FPM_MEMORY_LIMIT}/" $CONF_FPMOVERRIDES
fi

if [[ $PHP_FPM_MAX_EXECUTION_TIME ]]
then
  echo "[php-fpm] setting FPM max_execution_time ${PHP_FPM_MAX_EXECUTION_TIME}"
  sed -i "s/max_execution_time = .*/max_execution_time = ${PHP_FPM_MAX_EXECUTION_TIME}/" $CONF_FPMOVERRIDES
fi

if [[ $PHP_FPM_UPLOAD_MAX_FILESIZE ]]
then
  echo "[php] setting max_upload_filesize/post_max_size to ${PHP_FPM_UPLOAD_MAX_FILESIZE}"
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_FPM_UPLOAD_MAX_FILESIZE}/" $CONF_FPMOVERRIDES
  sed -i "s/post_max_size = .*/post_max_size = ${PHP_FPM_UPLOAD_MAX_FILESIZE}/" $CONF_FPMOVERRIDES
fi

if [[ $CONTAINER_ROLE != 'web' ]]
then
  echo '[php-fpm] non-web mode, bypassing run sequence'
fi
