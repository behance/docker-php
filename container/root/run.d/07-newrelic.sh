#!/bin/bash

# When both App ID and license are provided, automatically enable extension
if [ $REPLACE_NEWRELIC_APP ] && [ $REPLACE_NEWRELIC_LICENSE ]
then
  echo "[newrelic] enabling APM metrics for ${REPLACE_NEWRELIC_APP}"
  sed -i 's/;extension\s\?=/extension =/' $CONF_PHPMODS/newrelic.ini

  if [ "$NEWRELIC_TRACING_ENABLED" = "true" ]
  then
    echo "[newrelic] enabling tracing for ${REPLACE_NEWRELIC_APP}"
    sed -i "s/;newrelic.transaction_tracer.enabled = .*/newrelic.transaction_tracer.enabled = true/" $CONF_PHPMODS/newrelic.ini
    sed -i "s/;newrelic.distributed_tracing_enabled = .*/newrelic.distributed_tracing_enabled = true/" $CONF_PHPMODS/newrelic.ini
  fi
fi
