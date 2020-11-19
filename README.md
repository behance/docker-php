[![Build Status](https://travis-ci.org/behance/docker-php.svg?branch=master)](https://travis-ci.org/behance/docker-php)
[![Docker Pulls](https://img.shields.io/docker/pulls/bryanlatten/docker-php.svg?maxAge=2592000)]()

docker-php
===========

Provides a pre-wired, configurable PHP + Nginx setup across multiple runtime versions.

Integrated with Behance’s [docker-nginx](https://github.com/behance/docker-nginx)

Available on [Docker Hub](https://hub.docker.com/r/behance/docker-php/).

### Quick-start

- `docker run behance/docker-php:5.6 "php" "-v"`
- `docker run behance/docker-php:7.0 "php" "-v"`
- `docker run behance/docker-php:7.1 "php" "-v"`
- `docker run behance/docker-php:7.2 "php" "-v"`
- `docker run behance/docker-php:7.3-alpine "php" "-v"`
- `docker run behance/docker-php:7.3" "php" "-v"`
- `docker run behance/docker-php:7.4" "php" "-v"`

Adding code to runtime, see [here](https://github.com/behance/docker-php#expectations).
PHP tuning and configuration, see [here](https://github.com/behance/docker-php#downstream-configuration).
Nginx tuning and configuration, see [here](https://github.com/behance/docker-nginx#environment-variables).
Adding startup logic, [basic](https://github.com/behance/docker-base#startupruntime-modification) or [advanced](https://github.com/behance/docker-base#advanced-modification).

#### Container tag scheme: `PHP_MAJOR.PHP_MINOR(-Major.Minor.Patch)(-variant)`

- `PHP_MAJOR.PHP_MINOR`, required. Engine versions of PHP. ex. `docker-php:7.4`
- `(Major.Minor.Patch)`, optional. Semantically versioned container provisioning code. ex. `docker-php:7.3-13.4.0`.
- `(-variant)`, optional. Alpine variants are slim versions of the container. ex. `docker-php:7.3-alpine`.

### Includes
---

- [Nginx](https://github.com/behance/docker-nginx) HTTP server
- PHP / PHP-FPM: primary runtime
- [S6](https://github.com/just-containers/s6-overlay): PID 1 zombie reaping, startup coordination, shutdown signal transferal. Nginx and PHP are preconfigured to shutdown as gracefully as possible.
- [Goss](https://goss.rocks): for serverspec-like testing. Run `goss -g /tests/php-fpm/{PHP_MAJOR.PHP_MINOR}(-variant).goss.yaml` to validate any configuration updates
- Ubuntu (default) or Alpine OS [base](https://github.com/behance/docker-base)
- Common PHP extensions:

For extension customization, including enabling and disabling defaults, see [here](https://github.com/behance/docker-php#downstream-configuration)

`^`  - not available on `-alpine` variant
`*`  - not available on `7.2+`
`~`  - disabled by default

  - apcu
  - bcmath
  - bz2
  - calendar
  - ctype
  - curl
  - date
  - dom
  - exif
  - cgi-fcgi
  - gd
  - iconv
  - igbinary
  - intl
  - json
  - mbstring
  - mcrypt *
  - memcache ^
  - memcached
  - msgpack
  - mysqli
  - mysqlnd
  - newrelic ~ (activates with env variables)
  - opcache
  - openssl
  - pcntl
  - pdo
  - pdo_mysql
  - pdo_pgsql ~
  - pgsql ~
  - phar
  - posix
  - redis ~
  - shmop
  - SimpleXML
  - sockets
  - sysvmsg
  - sysvsem
  - sysvshm
  - tokenizer
  - xdebug ~,*
  - xml
  - xmlreader
  - xmlwriter
  - yaml ~
  - zip
  - zlib



### Expectations
---

Sample `Dockerfile`
```
FROM behance/docker-php:7.4

# (optional, recommended) Verify everything is in order from the parent
RUN goss -g /tests/php-fpm/7.4.goss.yaml validate && /aufs_hack.sh

# Layer local code into runtime
COPY ./ /app/

# Done!
```

- Local code should be copied into `/app`, for example:
```COPY ./ /app/```
- Nginx is pre-configured to use a front controller PHP file  (entrypoint)
a front controller called `index.php` within a `public` folder. `/app/public/index.php`

- Dev Mode (no ENV variables): PHP's opcache is enabled, and is set to check files for updates. Code can be developed locally in Docker by mounting into the `/app` folder.
For example, the `docker-compose.yml` syntax:
```
volumes:
   - ./:/app
```
- Production Mode [recommended]: using ENV variable, `CFG_APP_DEBUG=0`. Container becomes immutable, PHP's opcache is configured to not check files for updates.
- NOTE: Nginx is exposed and bound to an unprivileged port, `8080`.

### Monitoring
---
- NewRelic APM: automatically enabled by adding providing environment variables `REPLACE_NEWRELIC_APP` and `REPLACE_NEWRELIC_LICENSE`
- NewRelic Distributed Tracing: Before enabling distributed tracing be sure to read the [transition guide](https://docs.newrelic.com/docs/apm/distributed-tracing/getting-started/transition-guide-distributed-tracing). To enable this set `NEWRELIC_TRACING_ENABLED` to `true`.
- NewRelic Loglevel: you can override the NewRelic `newrelic.loglevel` and `newrelic.daemon.loglevel` config defaults (currently `warning`) to something more verbose for debugging purposes by setting environment variable `NEWRELIC_LOGLEVEL` to an available option (options include `info`, `debug`, `verbosedebug`)
- NewRelic Special: NewRelic has a `newrelic.special` config for special debug (sometimes requested by the NewRelic support team), you can turn that option on as directed by NewRelic support by setting enviroment variable `NEWRELIC_SPECIAL` to whatever value requested.
- PHP-FPM Status: available *only* inside container at `/__status`. Application healthcheck can pull PHP-FPM statistics from `http://127.0.0.1/__status?json`. To open to more clients than local, add more `allow` statements in `__status` location block in `$CONF_NGINX_SITE`(`/etc/nginx/sites-available/default`)
- Nginx Status: available *only* inside container at `/__nginx_status`. Application healthcheck can pull nginx statistics from `http://127.0.0.1/__nginx_status`. To open to more clients than local, add more `allow` statements in `__nginx_status` location block in $CONF_NGINX_SITE (`/etc/nginx/sites-available/default`)

### Downstream Configuration
---

#### PHP Extensions

A variety of common extensions are included, and can be enabled or disabled as needed.

##### To `enable` a built-in and disabled extension:

On Ubuntu (default):
```(bash)
# phpenmod XXX
```

On Alpine variant:
```(bash)
# sed -i "s/^;ext/ext/" $CONF_PHPMODS/XXX.ini
```

##### To `disable` a built-in extension:

On Ubuntu (default):
```(bash)
# phpdismod XXX
```

On Alpine variant:
```(bash)
# sed -i "s/ext/;ext/" $CONF_PHPMODS/XXX.ini
```




#### Environment variables

Environment variables can be used to tune various PHP-FPM and Nginx parameters without baking them in.

See parent(s) for additional configuration options:
- [docker-nginx](https://github.com/behance/docker-nginx)
- [docker-base](https://github.com/behance/docker-base)


Variable | Example | Default | Description
--- | --- | --- | ---
(all) | DATABASE_HOST=master.rds.aws.com | - | PHP has access to environment variables by default
CFG_APP_DEBUG | CFG_APP_DEBUG=1 | 1 | Setting to `1` or `true` will cue the Opcache to watch for file changes. Set to 0 for *production mode*, which provides a sizeable performance boost, though manually updating a file will not be seen unless the opcache is reset.
CFG_XDEBUG_ENABLE | CFG_XDEBUG_ENABLE=1 | - | Setting to `1` or `true` will enable the XDebug extension, which is preconfigured to allow remote debugging as well as profiling. NOTE: Requires "dev" mode be enabled via `CFG_APP_DEBUG`.
SERVER_MAX_BODY_SIZE | SERVER_MAX_BODY_SIZE=4M | 1M | Allows the downstream application to specify a non-default `client_max_body_size` configuration for the `server`-level directive in `/etc/nginx/sites-available/default`
SERVER_FASTCGI_BUFFERS | SERVER_FASTCGI_BUFFERS='512 32k' | 256 16k | [docs](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_buffers), [tweaking](https://gist.github.com/magnetikonline/11312172#determine-actual-fastcgi-response-sizes)
SERVER_FASTCGI_BUFFER_SIZE | SERVER_FASTCGI_BUFFER_SIZE='256k' | 128k | [docs](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_buffers_size), [tweaking](https://gist.github.com/magnetikonline/11312172#determine-actual-fastcgi-response-sizes)
SERVER_FASTCGI_BUSY_BUFFERS_SIZE | SERVER_FASTCGI_BUSY_BUFFERS_SIZE='1024k' | 256k | [docs](http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_busy_buffers_size)
REPLACE_NEWRELIC_APP | REPLACE_NEWRELIC_APP=prod-server-abc | - | Sets application name for newrelic
REPLACE_NEWRELIC_LICENSE | REPLACE_NEWRELIC_LICENSE=abcdefg | - | Sets license for newrelic, when combined with above, will enable newrelic reporting
NEWRELIC_TRACING_ENABLED | NEWRELIC_TRACING_ENABLED=true | disabled | Sets transaction_tracer and distributed_tracing true for newrelic, when combined with above, will enable [newrelic distributed tracing](https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-distributed-enabled)
NEWRELIC_LOGLEVEL | NEWRELIC_LOGLEVEL=verbosedebug | - | Overrides sane default loglevels for `newrelic.loglevel` and `newrelic.daemon.loglevel` (options include `warning`, `info`, `debug`, `verbosedebug`)
NEWRELIC_SPECIAL | NEWRELIC_SPECIAL=debug_autorum | - | Special NewRelic environment variable, for use with NewRelic support for when doing special debugging.
PHP_FPM_MEMORY_LIMIT | PHP_FPM_MEMORY_LIMIT=256M | 192MB | Sets memory limit for FPM instances of PHP
PHP_FPM_MAX_EXECUTION_TIME | PHP_FPM_MAX_EXECUTION_TIME=30 | 60 | Sets time limit for FPM workers
PHP_FPM_UPLOAD_MAX_FILESIZE | PHP_FPM_UPLOAD_MAX_FILESIZE=100M | 1M | Sets both upload_max_filesize and post_max_size
PHP_FPM_MAX_CHILDREN | PHP_FPM_MAX_CHILDREN=15 | 4096 | [docs](http://php.net/manual/en/install.fpm.configuration.php)
PHP_FPM_START_SERVERS | PHP_FPM_START_SERVERS=40 | 20 | [docs](http://php.net/manual/en/install.fpm.configuration.php)
PHP_FPM_MAX_REQUESTS | PHP_FPM_MAX_REQUESTS=100 | 1024 | [docs](http://php.net/manual/en/install.fpm.configuration.php) How many requests an individual FPM worker will process before recycling
PHP_FPM_MIN_SPARE_SERVERS | PHP_FPM_MIN_SPARE_SERVERS=10 | 5 | [docs](http://php.net/manual/en/install.fpm.configuration.php)
PHP_OPCACHE_MEMORY_CONSUMPTION | PHP_OPCACHE_MEMORY_CONSUMPTION=512 | 128 | [docs](http://php.net/manual/en/opcache.configuration.php#ini.opcache.memory-consumption)
PHP_OPCACHE_MAX_WASTED_PERCENTAGE | PHP_OPCACHE_MAX_WASTED_PERCENTAGE=10 | 5 | [docs](http://php.net/manual/en/opcache.configuration.php#ini.opcache.max-wasted-percentage)
PHP_OPCACHE_INTERNED_STRINGS_BUFFER | PHP_OPCACHE_INTERNED_STRINGS_BUFFER=64 | 16 | [docs](http://php.net/manual/en/opcache.configuration.php#ini.opcache.interned-strings-buffer)
PHP_OPCACHE_FILE_CACHE | PHP_OPCACHE_FILE_CACHE | /tmp | [docs](https://www.php.net/manual/en/opcache.configuration.php#ini.opcache.file-cache)
PHP_OPCACHE_ENABLE_CLI | PHP_OPCACHE_ENABLE_CLI | 1 | [docs](https://www.php.net/manual/en/opcache.configuration.php#ini.opcache.enable-cli)
PHP_FPM_LOG_LIMIT | PHP_FPM_LOG_LIMIT=4096 | 1024 | PHP 7.3-only, allows configurable stdout message max length [docs](https://www.php.net/manual/en/install.fpm.configuration.php)
PHP_FPM_LOG_BUFFERING | PHP_FPM_LOG_BUFFERING=no | yes | Experimental, PHP 7.3-only [docs](https://www.php.net/manual/en/install.fpm.configuration.php)

### Testing
---
- Requires `bash`, `docker`, `docker-compose`, and `dgoss`

To test locally, run `PHP_VARIANT=7.4 ./test.sh {docker engine IP}`.

This will:
- Build a single container `PHP_VARIANT` (7.0, 7.1, 7.2, 7.3, 7.3-alpine, 7.4)
- Leverages [Goss](https://goss.rocks) to confirm package, config, and extension installation
- Validates a large file upload
- Boots container with specific NewRelic configuration overrides

The test matrix is run automatically per pull request on Travis CI.

