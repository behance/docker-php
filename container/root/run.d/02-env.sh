#!/bin/bash

# Check if there are environment variables prefixed with `CFG_`.
if [[ $(env | grep ^CFG_ | wc -l) -ne 0 ]]
then
  # Adds docker environment variables where entering them as PHP-FPM environment variables
  VARS=`env | grep ^CFG_`
  DEST_CONF=/etc/php5/fpm/pool.d/www.conf

  echo '[env] importing environment variables (prefixed by CFG_)'
  for p in $VARS
  do
    ENV='env['${p/=/] = \"}\"
    echo $ENV >> $DEST_CONF
  done

else
  echo "[env] There were no environment variables found prefixed by CFG_"
fi
