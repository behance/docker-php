[![Build Status](https://travis-ci.org/bryanlatten/docker-php.svg?branch=master)](https://travis-ci.org/bryanlatten/docker-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/bryanlatten/docker-php.svg?maxAge=2592000)]()

docker-php
==========

Provides basic building blocks for PHP web applications, available on [Docker Hub](https://hub.docker.com/r/bryanlatten/docker-php/)  
Add’s PHP-FPM, mods, and specific backend configuration to Behance’s [docker-nginx](https://github.com/behance/docker-nginx)


Three variants are available:
- (default) Ubuntu-based, PHP 7.0  
- (slim) Alpine-based, PHP 7.0, tagged as `-alpine`  
- (beta) Ubuntu-based, PHP 7.1, tagged as `-beta`  
- (legacy) Ubuntu-based, PHP 5.6, tagged as `-legacy`  

###Includes
---
- Nginx
- PHP/PHP-FPM (7.0, 7.1, 5.6)
- S6: for PID 1 zombie reaping, startup coordination, shutdown signal transferal
- Goss: for serverspec-like testing. Run `goss -g /tests/php-fpm/{variant_name}.goss.yaml` to validate any configuration updates
- Extra PHP Modules:

`*`  - not available on Alpine variant  
`^`  - not available on Beta tag  
`~`  - disabled by default (use `phpenmod` to enable on Ubuntu-based variants, uncomment .ini file otherwise)
  - apc*^ (only visible for backwards compatibility) 
  - apcu^
  - calendar
  - bz2
  - ctype
  - curl
  - date
  - dom
  - exif
  - fpm
  - gd
  - gearman*^
  - iconv
  - igbinary*
  - intl
  - json
  - mbstring
  - mcrypt
  - memcache*^
  - memcached
  - mysqli
  - mysqlnd
  - newrelic~ (activates with env variables)
  - opcache
  - openssl
  - pcntl
  - pdo
  - pdo_mysql
  - pdo_pgsql~
  - pgsql~
  - phar
  - posix
  - redis~^
  - shmop
  - SimpleXML
  - sockets
  - sysvmsg
  - sysvsem
  - sysvshm
  - xdebug~^
  - xml
  - xmlreader
  - xmlwriter
  - yaml*~
  - zip
  - zlib



###Expectations
---
Applications that leverage `bryanlatten/docker-php` as their container parent are expected to copy their application into `/app`, for example:
```COPY ./ /app/```

Inside the copied directory, there must be a directory named `public` -- this will be automatically assigned as the webroot for the web server, which expects
a front controller called `index.php`.

Production Mode: an immutable container (without file updates) should set `CFG_APP_DEBUG=0` for max PHP performance  

NOTE: Nginx is exposed and bound to an unprivileged port, `8080`  

####Monitoring
--- 
1. NewRelic APM: automatically enabled by adding providing environment variables `REPLACE_NEWRELIC_APP` and `REPLACE_NEWRELIC_LICENSE`
1. PHP-FPM Status: available *only* inside container at `/__status`. Application healthcheck can pull PHP-FPM statistics from `http://127.0.0.1/__status?json`. To open to more clients than local, add more `allow` statements in `__status` location block in `$CONF_NGINX_SITE`(`/etc/nginx/sites-available/default`)
1. Nginx Status: available *only* inside container at `/__nginx_status`. Application healthcheck can pull nginx statistics from `http://127.0.0.1/__nginx_status`. To open to more clients than local, add more `allow` statements in `__nginx_status` location block in $CONF_NGINX_SITE (`/etc/nginx/sites-available/default`) 

###Downstream Configuration
---
Several environment variables can be used to configure various PHP FPM paramaters, as well as a few Nginx configurations.
as such. These can be used to drive the configuration of the downstream PHP application in any way necessary, but there are a few environment variables that `bryanlatter/docker-php` will process along the way...

See parent(s) [docker-nginx](https://github.com/behance/docker-nginx), [docker-base](https://github.com/behance/docker-base) for additional configuration


Variable | Example | Default | Description
--- | --- | --- | ---
`*` | `DATABASE_HOST=master.rds.aws.com` | - | PHP has access to environment variables by default
`CFG_APP_DEBUG` | `CFG_APP_DEBUG=1` | 1 | Set to `1` or `true` will cue the Opcache to watch for file changes. Set to 0 for *production mode*, which provides a sizeable performance boost, though manually updating a file will not be seen unless the opcache is reset.
`SERVER_MAX_BODY_SIZE` | `SERVER_MAX_BODY_SIZE=4M` | 1M | Allows the downstream application to specify a non-default `client_max_body_size` configuration for the `server`-level directive in `/etc/nginx/sites-available/default`
`SERVER_FASTCGI_BUFFERS` | `SERVER_FASTCGI_BUFFERS=‘512 32k’` | 256 16k | [docs](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_buffers), [tweaking](https://gist.github.com/magnetikonline/11312172#determine-actual-fastcgi-response-sizes)
`SERVER_FASTCGI_BUFFER_SIZE` | `SERVER_FASTCGI_BUFFER_SIZE=‘256k’` | 128k | [docs](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_buffers_size), [tweaking](https://gist.github.com/magnetikonline/11312172#determine-actual-fastcgi-response-sizes)
`SERVER_FASTCGI_BUSY_BUFFERS_SIZE` | `SERVER_FASTCGI_BUSY_BUFFERS_SIZE=‘1024k’` | 256k | [docs](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_busy_buffers_size)
`REPLACE_NEWRELIC_APP` | `REPLACE_NEWRELIC_APP=prod-server-abc` | - | Sets application name for newrelic
`REPLACE_NEWRELIC_LICENSE` | `REPLACE_NEWRELIC_LICENSE=abcdefg` | - | Sets license for newrelic, when combined with above, will enable newrelic reporting
`PHP_FPM_MEMORY_LIMIT` | `PHP_FPM_MEMORY_LIMIT=256M` | 192MB | Sets memory limit for FPM instances of PHP
`PHP_FPM_MAX_EXECUTION_TIME` | `PHP_FPM_MAX_EXECUTION_TIME=30` | 60 | Sets time limit for FPM workers
`PHP_FPM_UPLOAD_MAX_FILESIZE` | `PHP_FPM_UPLOAD_MAX_FILESIZE=100M` | 1M | Sets both upload_max_filesize and post_max_size
`PHP_FPM_MAX_CHILDREN` | `PHP_FPM_MAX_CHILDREN=15` | 4096 | [docs](http://php.net/manual/en/install.fpm.configuration.php)
`PHP_FPM_START_SERVERS` | `PHP_FPM_START_SERVERS=40` | 20 | [docs](http://php.net/manual/en/install.fpm.configuration.php)
`PHP_FPM_MAX_REQUESTS` | `PHP_FPM_MAX_REQUESTS=100` | 1024 | [docs](http://php.net/manual/en/install.fpm.configuration.php) How many requests an individual FPM worker will process before recycling
`PHP_FPM_MIN_SPARE_SERVERS` | `PHP_FPM_MIN_SPARE_SERVERS=10` | 5 | [docs](http://php.net/manual/en/install.fpm.configuration.php)
`PHP_OPCACHE_MEMORY_CONSUMPTION` | `PHP_OPCACHE_MEMORY_CONSUMPTION=512` | 128 | [docs](http://php.net/manual/en/opcache.configuration.php#ini.opcache.memory-consumption)
`PHP_OPCACHE_MAX_WASTED_PERCENTAGE` | `PHP_OPCACHE_MAX_WASTED_PERCENTAGE=10` | 5 | [docs](http://php.net/manual/en/opcache.configuration.php#ini.opcache.max-wasted-percentage)
`PHP_OPCACHE_INTERNED_STRINGS_BUFFER` | `PHP_OPCACHE_INTERNED_STRINGS_BUFFER=64` | 16 | [docs](http://php.net/manual/en/opcache.configuration.php#ini.opcache.interned-strings-buffer)