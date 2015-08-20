docker-php
==========

Provides basic building blocks for PHP web applications

###Includes
---
- Nginx
- PHP/PHP-FPM (5.6)
- Extra PHP Modules:
  - apcu
  - curl
  - gearman
  - igbinary
  - intl
  - mcrypt
  - memcache
  - memcached (yes, both...)
  - mysqlnd
  - Zend Opcache
  - Xdebug (disabled by default)

###Expectations
---
Applications that leverage `bryanlatten/docker-php` in their Dockerfile are expected have a root directory in their source code named `public` -- this will be automatically assigned as the webroot for the web server.

Development libraries are made available (php5-dev) for downstream app to use to add dependencies, such as PECL modules. Please run /clean.sh at the end of a child build to ensure these packages are removed before production.

###Downstream Configuration
---
Several environment variables can be used to configure various PHP FPM paramaters, as well as a few Nginx configurations. By default, all `CFG_*` environment variables are ingested by the FPM process
as such. These can be used to drive the configuration of the downstream PHP application in any way necessary, but there are a few environment variables that `bryanlatter/docker-php` will process along the way...

Variable | Example | Description
--- | --- | ---
`CFG_*` | `CFG_DATABASE_USERNAME=root` | Ingested into `/etc/php5/fpm/pool.d/www.conf` for PHP to access as an environment variable
`CFG_APP_DEBUG` | `CFG_APP_DEBUG=1` | Setting to `1` or `true` will cue the Opcache to watch for file changes as well as increase Nginx's default buffer sizes, suitable for Development Mode. Otherwise, headers are normal and the Opcache check is skipped for a performance boost.
`SERVER_MAX_BODY_SIZE` | `SERVER_MAX_BODY_SIZE=4M` | Allows the downstream application to specify a non-default `client_max_body_size` configuration for the `server`-level directive in `/etc/nginx/sites-available/default`
`REPLACE_NEWRELIC_APP` | `REPLACE_NEWRELIC_APP=prod-server-abc` | Sets application name for newrelic
`REPLACE_NEWRELIC_LICENSE` | `REPLACE_NEWRELIC_LICENSE=abcdefg` | Sets license for newrelic, when combined with above, will enable newrelic reporting

