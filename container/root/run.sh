#!/bin/bash

# As part of the "Two Phase" build, the first phase typically runs with composer keys mounted,
# allowing the dependencies to be installed, the result of which is committed
if [[ -f /root/.composer/config.json ]]
then
  echo "Running `composer install`"
  composer install
  # Container exits after installation

else
  # Adds docker environment variables where entering them as PHP-FPM environment variables
  VARS=`env | grep ^CFG_`;
  DEST_CONF=/etc/php5/fpm/pool.d/www.conf

  echo 'Importing environment variables (prefixed by CFG_)'
  for p in $VARS
  do
    ENV='env['${p/=/] = \"}\"
    echo $ENV >> $DEST_CONF
  done

  if [[ $CFG_APP_DEBUG = 1 || $CFG_APP_DEBUG = '1' || $CFG_APP_DEBUG = 'true' ]]
  then
    echo 'Opcache set to WATCH for file changes'
  else
    echo 'Opcache set to PERFORMANCE, NOT watching for file changes'
    echo 'opcache.revalidate_freq=0' >> /etc/php5/mods-available/opcache.ini
    echo 'opcache.validate_timestamps=0' >> /etc/php5/mods-available/opcache.ini
  fi

  echo 'Setting sensible PHP defaults'
  php5enmod defaults

  # Configure nginx to use as many workers as there are cores for the running container
  sed -i "s/worker_processes [0-9]\+/worker_processes $(nproc)/" /etc/nginx/nginx.conf
  sed -i "s/worker_connections [0-9]\+/worker_connections 1024/" /etc/nginx/nginx.conf

  # Ensure nginx is configured to write logs to STDOUT
  sed -i "s/access_log [a-z\/\.\;]\+/access_log \/dev\/stdout;/" /etc/nginx/nginx.conf
  sed -i "s/error_log [a-z\/\.\ \;]\+/error_log \/dev\/stdout info;/" /etc/nginx/nginx.conf

  # Baseline "optimizations" before ApacheBench succeeded at concurrency of 150
  # TODO: base on current memory capacity + CPU cores
  sed -i "s/pm.max_children = [0-9]\+/pm.max_children = 48/" /etc/php5/fpm/pool.d/www.conf
  sed -i "s/pm.start_servers = [0-9]\+/pm.start_servers = 16/" /etc/php5/fpm/pool.d/www.conf
  sed -i "s/pm.min_spare_servers = [0-9]\+/pm.min_spare_servers = 4/" /etc/php5/fpm/pool.d/www.conf
  sed -i "s/pm.max_spare_servers = [0-9]\+/pm.max_spare_servers = 32/" /etc/php5/fpm/pool.d/www.conf

  # Allow php5-fpm process to pick up stdout and stderr from worker processes
  sed -i "s/;catch_workers_output/catch_workers_output/" /etc/php5/fpm/pool.d/www.conf

  echo 'Starting PHP-FPM (background)'
  # php5-fpm --nodaemonize 1> >(sed -u 's/WARNING: \[pool www\] child [0-9]* said into stdout: \"\(.*\)\"$/\1/' >/dev/stdout) \
  #                        2> >(sed -u 's/WARNING: \[pool www\] child [0-9]* said into stderr: \"\(.*\)\"$/\1/' >/dev/stderr) &
  php5-fpm --nodaemonize &

  echo "Starting Nginx (foreground)"
  exec /usr/sbin/nginx -g "daemon off;"


fi
