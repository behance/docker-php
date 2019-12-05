#!/bin/bash

#---------------------------------------------------------------------------------
# A standard set of tweaks to ensure container
# runs performant, reliably, and consistent between variants
#---------------------------------------------------------------------------------

sed -i "s/;*error_log = .*/error_log = \/dev\/stdout/" $CONF_PHPFPM

# - Configure php-fpm to use TCP rather than unix socket (for stability), fastcgi_pass is also set by /etc/nginx/sites-available/default
sed -i "s/listen = .*/listen = 127.0.0.1:9000/" $CONF_FPMPOOL

# - Set base directory for all php (/app), difficult to use APP_PATH as a replacement, otherwise / breaks command \
sed -i "s/;chdir =.*/chdir = \/app/" $CONF_FPMPOOL

# - Ensure performance management knobs are exposed to environment variables
sed -i "s/pm.max_children = .*/pm.max_children = \${PHP_FPM_MAX_CHILDREN}/" $CONF_FPMPOOL
sed -i "s/pm.start_servers = .*/pm.start_servers = \${PHP_FPM_START_SERVERS}/" $CONF_FPMPOOL
sed -i "s/;*pm.max_requests = .*/pm.max_requests = \${PHP_FPM_MAX_REQUESTS}/" $CONF_FPMPOOL
sed -i "s/pm.min_spare_servers = .*/pm.min_spare_servers = \${PHP_FPM_MIN_SPARE_SERVERS}/" $CONF_FPMPOOL
sed -i "s/pm.max_spare_servers = .*/pm.max_spare_servers = \${PHP_FPM_MAX_SPARE_SERVERS}/" $CONF_FPMPOOL

# Enable performance management status page at "/__status"
sed -i 's/;*pm.status_path = .*/pm.status_path = \/__status/' $CONF_FPMPOOL

# - Ensure environment variables aren't cleaned, will make it into FPM  workers \
sed -i "s/;clear_env.*/clear_env = no/" $CONF_FPMPOOL

# - php-fpm processes must pick up stdout/stderr from workers, will cause minor performance decrease (but is required) \
sed -i "s/;catch_workers_output.*/catch_workers_output = yes/" $CONF_FPMPOOL

# - Enforce ACL that only 127.0.0.1 may connect
sed -i "s/;listen.allowed_clients.*/listen.allowed_clients = 127.0.0.1/" $CONF_FPMPOOL

# - Since PHP-FPM will be run without root privileges, comment these lines to prevent any startup warnings
# sed -i "s/^user =/;user =/" $CONF_FPMPOOL
# sed -i "s/^group =/;group =/" $CONF_FPMPOOL

# - Match FPM timeout directive with .ini max execution time
sed -i "s/;*request_terminate_timeout = .*/request_terminate_timeout = \${PHP_FPM_MAX_EXECUTION_TIME}/" $CONF_FPMPOOL

# - Set open file descriptor rlimit for the master php-fpm process.
sed -i "s/^;rlimit_files =.*/rlimit_files = 40000/" $CONF_FPMPOOL

# - Set max core size rlimit for the master process.
sed -i "s/^;rlimit_core =.*/rlimit_core = unlimited/" $CONF_FPMPOOL

# - Allow NewRelic to be partially configured by environment variables, set sane defaults

# Enable NewRelic via Ubuntu symlinks, but disable in file. Cross-variant startup script uncomments with env vars.
sed -i 's/extension\s\?=/;extension =/' $CONF_PHPMODS/newrelic.ini
sed -i "s/newrelic.appname = .*/newrelic.appname = \"\${REPLACE_NEWRELIC_APP}\"/" $CONF_PHPMODS/newrelic.ini
sed -i "s/newrelic.license = .*/newrelic.license = \"\${REPLACE_NEWRELIC_LICENSE}\"/" $CONF_PHPMODS/newrelic.ini
sed -i "s/newrelic.logfile = .*/newrelic.logfile = \"\/dev\/stdout\"/" $CONF_PHPMODS/newrelic.ini
sed -i "s/newrelic.daemon.logfile = .*/newrelic.daemon.logfile = \"\/dev\/stdout\"/" $CONF_PHPMODS/newrelic.ini
sed -i "s/;newrelic.loglevel = .*/newrelic.loglevel = \"warning\"/" $CONF_PHPMODS/newrelic.ini
sed -i "s/;newrelic.daemon.loglevel = .*/newrelic.daemon.loglevel = \"warning\"/" $CONF_PHPMODS/newrelic.ini

# Set nginx to listen on defined port \
sed -i "s/listen [0-9]*;/listen ${CONTAINER_PORT};/" $CONF_NGINX_SITE

# - Required for php-fpm to place .sock file into, fails otherwise
mkdir -p /var/run/php/
mkdir -p /var/run/lock/
mkdir -p /var/log/newrelic/

chown -R $NOT_ROOT_USER:$NOT_ROOT_USER /var/run/php /var/run/lock /var/log/newrelic
