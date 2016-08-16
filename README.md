[![Build Status](https://travis-ci.org/bryanlatten/docker-php.svg?branch=master)](https://travis-ci.org/bryanlatten/docker-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/bryanlatten/docker-php.svg?maxAge=2592000)]()

docker-php
==========

Provides basic building blocks for PHP web applications, available on Docker Hub: https://hub.docker.com/r/bryanlatten/docker-php/

Three variants are available:
- (default) Ubuntu-based, PHP 7.0  
- (slim) Alpine-based, PHP 7.0, tagged as `-alpine`  
- (beta) Ubuntu-based, PHP 7.1, tagged as `-beta`  

###Includes
---
- Nginx
- PHP/PHP-FPM (7.0)
- Extra PHP Modules:

`*` - not available on Alpine variant  
`**` - backwards compatible library not available on Alpine variant  
`^` - not available on beta tag  
`~` - disabled by default (use `phpenmod` to enable on Ubuntu-based variants, uncomment .ini file otherwise)
  - apcu**^
  - bz2^
  - ctype
  - curl
  - dom
  - exif
  - fpm
  - gd
  - gearman*
  - iconv
  - igbinary*^
  - intl
  - json
  - mbstring
  - mcrypt
  - memcache*^
  - memcached^
  - mysqli
  - mysqlnd
  - newrelic~ (activates with env variables)
  - opcache (can be disabled with debug env variable)
  - openssl
  - pcntl
  - pdo
  - pdo_mysql
  - pdo_pgsql~
  - pgsql~
  - phar
  - posix
  - redis~
  - shmop
  - SimpleXML
  - sockets
  - sysvmsg
  - sysvsem
  - sysvshm
  - xml
  - xmlreader
  - xmlwriter
  - zip
  - zlib
  - xdebug~


###Expectations
---
Applications that leverage `bryanlatten/docker-php` as their container parent are expected to copy their application into `/app`, for example:
```COPY ./ /app/```

Inside the copied directory, there must be a directory named `public` -- this will be automatically assigned as the webroot for the web server, which expects
a front controller called `index.php`.


NOTE: Nginx is exposed and bound to an unprivileged port, `8080`


###Downstream Configuration
---
Several environment variables can be used to configure various PHP FPM paramaters, as well as a few Nginx configurations.
as such. These can be used to drive the configuration of the downstream PHP application in any way necessary, but there are a few environment variables that `bryanlatter/docker-php` will process along the way...

Variable | Example | Description
--- | --- | ---
`CFG_*` | `CFG_DATABASE_USERNAME=root` | PHP has access as an environment variable
`CFG_APP_DEBUG` | `CFG_APP_DEBUG=1` | Setting to `1` or `true` will cue the Opcache to watch for file changes. Otherwise, the Opcache check is skipped for a performance boost.
`SERVER_MAX_BODY_SIZE` | `SERVER_MAX_BODY_SIZE=4M` | Allows the downstream application to specify a non-default `client_max_body_size` configuration for the `server`-level directive in `/etc/nginx/sites-available/default`
`REPLACE_NEWRELIC_APP` | `REPLACE_NEWRELIC_APP=prod-server-abc` | Sets application name for newrelic
`REPLACE_NEWRELIC_LICENSE` | `REPLACE_NEWRELIC_LICENSE=abcdefg` | Sets license for newrelic, when combined with above, will enable newrelic reporting
`PHP_FPM_MEMORY_LIMIT` | `PHP_FPM_MEMORY_LIMIT=256M` | Sets memory limit for FPM instances of PHP
`PHP_FPM_MAX_EXECUTION_TIME` | `PHP_FPM_MAX_EXECUTION_TIME=60` | Sets time limit for FPM workers
`PHP_FPM_UPLOAD_MAX_FILESIZE` | `PHP_FPM_UPLOAD_MAX_FILESIZE=100M` | Sets both upload_max_filesize and post_max_size

