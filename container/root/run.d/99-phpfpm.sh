#!/bin/sh

if [[ $CONTAINER_ROLE != 'web' ]]
then
  echo '[php-fpm] non-web mode, bypassing run sequence'
  exit
fi

if [[ $PHP_MEMORY_LIMIT ]]
then
  echo "[php] setting memory_limit ${PHP_MEMORY_LIMIT}"
  sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" $CONF_PHPINI
fi

if [[ $PHP_MAX_EXECUTION_TIME ]]
then
  echo "[php] setting max_execution_time ${PHP_MAX_EXECUTION_TIME}"
  sed -i "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" $CONF_PHPINI
fi

if [[ $PHP_UPLOAD_MAX_FILESIZE ]]
then
  echo "[php] setting max_upload_filesize to ${PHP_UPLOAD_MAX_FILESIZE}"
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" $CONF_PHPINI
  sed -i "s/post_max_size = .*/post_max_size = ${PHP_UPLOAD_MAX_FILESIZE}/" $CONF_PHPINI
fi

# 1. runs php-fpm as foreground (-F)
# 2. forcing php-fpm to log to stdout even if a non-terminal is attached (-O)
# 3. redirect stderr to stdout
# 4. filtering the garbage string that PHP-FPM for no-reason-at-all decided to wrap the message in,
# 5. reconnecting the stdout to current stdout
# 6. backgrounding that process chain
echo '[php-fpm] starting (background)'
php-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,"$,,' 1>&1 &
