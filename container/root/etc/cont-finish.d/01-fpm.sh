#!/bin/bash

# To produce an orderly stop, drain connections from the reverse proxy.
# Once the proxy has no active connections, plug can be pulled,
# as there are no more active connections.

echo "[finish php-fpm] starting graceful shutdown"

NGINX_ACTIVE=`pgrep nginx | wc -w`

if [ $NGINX_ACTIVE -ne 0 ]; then
  echo "[finish php-fpm] waiting for nginx to terminate"
  # wait $NGINX_PID; <-- does not work since not a child process
  # @see https://stackoverflow.com/questions/8048628/wait-child-process-but-get-error-pid-is-not-a-child-of-this-shell
  while [ `pgrep nginx | wc -w` -ne 0 ]; do sleep .10; done
  echo "[finish php-fpm] nginx terminated"
fi

echo "[finish php-fpm] shutting down"

# TODO: bypass FPM's clunky ungraceful shutdown, which breaks stdout and outputs ugly warnings
# @see https://stackoverflow.com/questions/36564074/nginx-php-fpm-graceful-stop-sigquit-not-so-graceful
# pkill -QUIT -o php-fpm

