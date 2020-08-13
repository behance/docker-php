#!/bin/bash

# Ensures that a failure of php-fpm doesn't return with a 0, even if the right-hand side does
set -o pipefail

# IMPORTANT: PHP 7.3+ optionally allows undecorated stdout/stderr, removes requirement for legacy post-filtering
grep "decorate_workers_output = no" "$CONF_FPMPOOL" 1>/dev/null
_RETVAL=$?

if [[ "${_RETVAL}" == "0" ]]; then
  echo '[php-fpm] launching...'
  exec php-fpm -F -O
else
  echo '[php-fpm] launching...with legacy filtered stdout'
  exec php-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,\"$,,'
fi
