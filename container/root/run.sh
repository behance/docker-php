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

    FASTCGI_PARAM_FILE=/etc/nginx/fastcgi_params
    echo 'Increasing fastcgi buffer size for debug headers'
    echo "" >> $FASTCGI_PARAM_FILE
    echo "# Debug Buffer Sizes" >> $FASTCGI_PARAM_FILE
    echo "fastcgi_buffer_size 16k;" >> $FASTCGI_PARAM_FILE
    echo "fastcgi_buffers 4 16k;" >> $FASTCGI_PARAM_FILE

  else
    echo 'Opcache set to PERFORMANCE, NOT watching for file changes'
    echo 'opcache.revalidate_freq=0' >> /etc/php5/mods-available/opcache.ini
    echo 'opcache.validate_timestamps=0' >> /etc/php5/mods-available/opcache.ini
  fi

  if [[ $SERVER_MAX_BODY_SIZE ]]
  then
    DEST_CONF_DEFAULT=/etc/nginx/sites-available/default
    DEST_CONF_DEFAULT_TMP=$DEST_CONF_DEFAULT.tmp

    # Create TMP config file, omitting the closing bracket
    head -n -1 $DEST_CONF_DEFAULT > $DEST_CONF_DEFAULT_TMP

    echo "Bumping client_max_body_size to $SERVER_MAX_BODY_SIZE"
    echo "  client_max_body_size $SERVER_MAX_BODY_SIZE;" >> $DEST_CONF_DEFAULT_TMP

    echo "}" >> $DEST_CONF_DEFAULT_TMP

    # Move the updated config into place
    mv $DEST_CONF_DEFAULT_TMP $DEST_CONF_DEFAULT
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

  # php5-fpm processes must pick up stdout/stderr from workers, will cause minor performance decrease (but is required)
  sed -i "s/;catch_workers_output/catch_workers_output/" /etc/php5/fpm/pool.d/www.conf


  # 1. runs php5-fpm as foreground (-F)
  # 2. forcing php5-fpm to log to stderr even if a non-terminal is attached (-O)
  # 3. redirect stderr to stdout
  # 4. filtering the garbage string that PHP-FPM for no-reason-at-all decided to wrap the message in,
  # 5. reconnecting the stdout to current stdout
  # 6. backgrounding that process
  echo 'Starting PHP-FPM (background)'
  php5-fpm -F -O 2>&1 | sed -u 's/WARNING: \[pool www\] child [0-9]* said into std[a-z]*: \"\(.*\)\"$/\1/' 1>&1 &

  echo "Starting Nginx (foreground)"
  exec /usr/sbin/nginx -g "daemon off;"

fi
