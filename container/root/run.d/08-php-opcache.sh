#!/bin/bash

if [[ $CFG_APP_DEBUG = 1 || $CFG_APP_DEBUG = '1' || $CFG_APP_DEBUG = 'true' ]]
then
  echo '[debug] Opcache WATCHING for file changes'
else
  echo '[debug] Opcache set to PERFORMANCE, NOT WATCHING for file changes'
fi
