#!/bin/sh

CONF_NEWRELIC="${CONF_PHPMODS}/newrelic.ini"

if [ $REPLACE_NEWRELIC_APP ] && [ $REPLACE_NEWRELIC_LICENSE ]
then
  echo "[newrelic] enabling APM metrics for ${REPLACE_NEWRELIC_APP}"
  sed -i "s/newrelic.appname = .*/newrelic.appname = \"${REPLACE_NEWRELIC_APP}\"/" $CONF_NEWRELIC
  sed -i "s/newrelic.license = .*/newrelic.license = \"${REPLACE_NEWRELIC_LICENSE}\"/" $CONF_NEWRELIC

  # Reenable the extension
  sed -i "s/;extension =/extension =/" $CONF_PHPMODS/newrelic.ini
fi
