#!/bin/bash

PHPFPM_CONF=/etc/php5/fpm/pool.d/www.conf

if [[ $CONTAINER_ROLE != 'web' ]]
then
  echo '[php-fpm] non-web mode, bypassing run sequence'
  exit
fi

# Baseline "optimizations" before ApacheBench succeeded at concurrency of 150
# @see http://www.codestance.com/tutorials-archive/install-and-configure-php-fpm-on-nginx-385
sed -i "s/pm.max_children = [0-9]\+/pm.max_children = 4096/" $PHPFPM_CONF
sed -i "s/pm.start_servers = [0-9]\+/pm.start_servers = 20/" $PHPFPM_CONF
sed -i "s/pm.min_spare_servers = [0-9]\+/pm.min_spare_servers = 5/" $PHPFPM_CONF
sed -i "s/pm.max_spare_servers = [0-9]\+/pm.max_spare_servers = 128/" $PHPFPM_CONF

sed -i "s/;pm.max_requests = [0-9]\+/pm.max_requests = 1024/" $PHPFPM_CONF

# Ensure environment variables aren't cleaned, will make it into FPM  workers
sed -i "s/;clear_env/clear_env/" $PHPFPM_CONF

# php5-fpm processes must pick up stdout/stderr from workers, will cause minor performance decrease (but is required)
sed -i "s/;catch_workers_output/catch_workers_output/" $PHPFPM_CONF

# 1. runs php5-fpm as foreground (-F)
# 2. forcing php5-fpm to log to stderr even if a non-terminal is attached (-O)
# 3. redirect stderr to stdout
# 4. filtering the garbage string that PHP-FPM for no-reason-at-all decided to wrap the message in,
# 5. reconnecting the stdout to current stdout
# 6. backgrounding that process
echo '[php-fpm] starting (background)'
php5-fpm -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,"$,,' 1>&1 &
