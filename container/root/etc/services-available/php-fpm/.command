#!/bin/bash

exec php5-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,\"$,,'
