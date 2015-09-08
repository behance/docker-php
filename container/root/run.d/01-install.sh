#!/bin/bash

# As part of the "Two Phase" build, the first phase typically runs with composer keys mounted,
# allowing the dependencies to be installed, the result of which is committed

if [[ -f /root/.composer/config.json ]]
then
  echo "[install] app dependencies"
  composer install --optimize-autoloader
  exit $SIGNAL_BUILD_STOP
fi
