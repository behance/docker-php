#!/bin/bash

# Ensures that a failure of php-fpm doesn't return with a 0, even if the right-hand side does
set -o pipefail

# IMPORTANT: PHP 7.3+ optionally allows undecorated stdout/stderr, removing pipe magic requirement
grep "decorate_workers_output = no" $CONF_FPMPOOL

if [ $? ]; then
  exec php-fpm -F -O
fi
else
  exec php-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,\"$,,'
fi
