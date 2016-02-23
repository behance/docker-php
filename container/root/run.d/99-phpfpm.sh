#!/bin/bash

#################################################
# Makes runtime changes to configuration
#################################################

if [[ $PHP_FPM_MEMORY_LIMIT ]]
then
  echo "[php] setting FPM memory_limit ${PHP_FPM_MEMORY_LIMIT}"
  sed -i "s/memory_limit = .*/memory_limit = ${PHP_FPM_MEMORY_LIMIT}/" $CONF_FPMOVERRIDES
fi

if [[ $PHP_FPM_MAX_EXECUTION_TIME ]]
then
  echo "[php] setting FPM max_execution_time ${PHP_FPM_MAX_EXECUTION_TIME}"
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
  exit
fi

# 1. runs php-fpm as foreground (-F)
# 2. forcing php-fpm to log to stdout even if a non-terminal is attached (-O)
# 3. redirect stderr to stdout
# 4. filtering the garbage string that PHP-FPM for no-reason-at-all decided to wrap the message in,
# 5. reconnecting the stdout to current stdout
# 6. backgrounding that process chain
echo '[php-fpm] starting (background)'
php5-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,"$,,' 1>&1 &
