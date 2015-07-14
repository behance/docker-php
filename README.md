docker-php
==========

Provides basic building blocks for PHP web applications

###Includes
--- 
- Nginx
- PHP-FPM (5.6)
- Extra PHP Modules:
  - apcu
  - curl
  - gearman
  - igbinary
  - mcrypt
  - memcache
  - memcached (yes, both...)
  - mysqlnd
  - Zend Opcache
  - Xdebug (disabled by default)

###Expectations
---
Applications that leverage `bryanlatten/docker-php` in their Dockerfile are expected have a root directory in their source code named `public` -- this will be automatically assigned as the webroot for the web server.
