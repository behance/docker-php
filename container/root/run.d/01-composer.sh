#!/bin/bash

# As part of the "Two Phase" build, the first phase typically runs with composer keys mounted,
# allowing the dependencies to be installed, the result of which is committed

if [[ -f /root/.composer/config.json ]]
then
  echo "[composer] installing app dependencies"
  composer install
  exit 99  # Signals for container to stop
fi
