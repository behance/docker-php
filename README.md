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

