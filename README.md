docker-php
==========

Provides basic building blocks for PHP web applications, available on Docker Hub: https://hub.docker.com/r/bryanlatten/docker-php/

Ubuntu used by default, Alpine builds also available tagged as `-alpine`

###Includes
---
- Nginx
- PHP/PHP-FPM (7.0)
- Extra PHP Modules:
  - apcu**
  - bz2
  - ctype
  - curl
  - dom
  - exif
  - fpm
  - gd
  - iconv
  - gearman*
  - igbinary*
  - intl
  - json
  - mcrypt
  - mysql
  - memcache*
  - memcached
  - mysqlnd
  - newrelic
  - pdo
  - pdo_mysql
  - opcache
  - openssl
  - phar
  - pcntl
  - posix
  - sockets
  - shmop
  - sysvsem
  - sysvshm
  - sysvmsg
  - xml
  - xmlreader
  - zip
  - zlib
  - ~xdebug~ (disabled by default)

* - not available on Alpine variant
** - backwards compatible library not available on Alpine variant

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

