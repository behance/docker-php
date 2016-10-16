#!/bin/bash

# When both App ID and license are provided, automatically enable extension
if [ $REPLACE_NEWRELIC_APP ] && [ $REPLACE_NEWRELIC_LICENSE ]
then
  echo "[newrelic] enabling APM metrics for ${REPLACE_NEWRELIC_APP}"
  sed -i 's/;extension\s\?=/extension =/' $CONF_PHPMODS/newrelic.ini
fi
