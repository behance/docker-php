#!/usr/bin/with-contenv bash

if [ $REPLACE_NEWRELIC_APP ] && [ $REPLACE_NEWRELIC_LICENSE ]
then
  echo "[newrelic] enabling APM metrics for ${REPLACE_NEWRELIC_APP}"
  sed -i 's/;extension\s\?=/extension =/' $CONF_PHPMODS/newrelic.ini
fi
