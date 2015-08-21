#!/bin/bash

# Adds docker environment variables where entering them as PHP-FPM environment variables
VARS=`env | grep ^CFG_`;
DEST_CONF=/etc/php5/fpm/pool.d/www.conf

echo '[env] importing environment variables (prefixed by CFG_)'
for p in $VARS
do
  ENV='env['${p/=/] = \"}\"
  echo $ENV >> $DEST_CONF
done
