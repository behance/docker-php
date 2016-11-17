#!/bin/bash

# Ensures that a failure of php-fpm doesn't return with a 0, even if the right-hand side does
set -o pipefail

exec php-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,\"$,,'
