#!/bin/bash

# As part of the "Two Phase" build, the first phase artifact is run with secrets (including composer keys) mounted,
# allowing the dependencies to be installed, the result of which is committed

# TODO: convert to optionally run during build with netcat/docker-bridge trick

if [[ -f /root/.composer/config.json ]]
then
  echo "[install] app dependencies"
  composer install --optimize-autoloader
  exit $SIGNAL_BUILD_STOP
fi
