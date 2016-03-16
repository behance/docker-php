#!/usr/bin/with-contenv bash

if [[ $CFG_APP_DEBUG = 1 || $CFG_APP_DEBUG = '1' || $CFG_APP_DEBUG = 'true' ]]
then
  echo '[debug] opcache disabled, WATCHING file changes'
  sed -i 's/zend_extension=/;zend_extension=/' $CONF_PHPMODS/opcache.ini
else
  echo '[debug] Opcache set to PERFORMANCE, NOT WATCHING for file changes'
fi
