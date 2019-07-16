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

  if [ "$NEWRELIC_LOGLEVEL" != "" ]
  then
    echo "[newrelic] replacing loglevel for ${REPLACE_NEWRELIC_APP} with '${NEWRELIC_LOGLEVEL}'"
    sed -i "s/.*newrelic.loglevel = .*/newrelic.loglevel = \"${NEWRELIC_LOGLEVEL}\"/" $CONF_PHPMODS/newrelic.ini
    sed -i "s/.*newrelic.daemon.loglevel = .*/newrelic.daemon.loglevel = \"${NEWRELIC_LOGLEVEL}\"/" $CONF_PHPMODS/newrelic.ini
  fi

  if [ "$NEWRELIC_SPECIAL" != "" ]
  then
    echo "[newrelic] adding in newrelic.special=${NEWRELIC_SPECIAL} debug value for ${REPLACE_NEWRELIC_APP}"
    grep -qxF "newrelic.special=${NEWRELIC_SPECIAL}" $CONF_PHPMODS/newrelic.ini || echo "newrelic.special=${NEWRELIC_SPECIAL}" >> $CONF_PHPMODS/newrelic.ini
  fi
fi
