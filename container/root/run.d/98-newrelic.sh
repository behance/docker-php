#!/bin/bash

NEWRELIC_CONF=/etc/php5/mods-available/newrelic.ini

if [[ $REPLACE_NEWRELIC_APP && $REPLACE_NEWRELIC_LICENSE ]]
then
  echo "[newrelic] enabling APM metrics for ${REPLACE_NEWRELIC_APP}"
  sed -i "s/newrelic.appname = \"REPLACE_NEWRELIC_APP\"/newrelic.appname = \"${REPLACE_NEWRELIC_APP}\"/" $NEWRELIC_CONF
  sed -i "s/newrelic.license = \"REPLACE_NEWRELIC_LICENSE\"/newrelic.license = \"${REPLACE_NEWRELIC_LICENSE}\"/" $NEWRELIC_CONF

  # IMPORTANT: change auto-launch parameter BACK from what was set in the Dockerfile
  sed -i "s/newrelic.daemon.dont_launch = 3/newrelic.daemon.dont_launch = 0/" $NEWRELIC_CONF
  php5enmod newrelic
fi
