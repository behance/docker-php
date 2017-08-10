#!/bin/bash

if [[ ($CFG_APP_DEBUG = 1 || $CFG_APP_DEBUG = '1' || $CFG_APP_DEBUG = 'true') && ($CFG_XDEBUG_ENABLE = 1 || $CFG_XDEBUG_ENABLE = '1' || $CFG_XDEBUG_ENABLE = 'true') ]]
then
  echo '[debug] Enabling XDebug extension'
  sed -i 's/^;zend_extension/zend_extension/' $CONF_PHPMODS/xdebug.ini
  if [ -x "$(command -v phpenmod)" ]; then
    phpenmod xdebug
  fi
else
  echo '[debug] XDebug remains disabled'
fi
