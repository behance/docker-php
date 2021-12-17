#!/bin/bash

ARCH=$(archstring --x64 x64 --arm64 arm64)

if [[ "$ARCH" == "x64" ]]; then
  # Locate and install latest Alpine-compatible NewRelic, seed with variables to be replaced
  # Requires PHP to already be installed
  NEWRELIC_MUSL_PATH=$(curl -s https://download.newrelic.com/php_agent/release/ | grep 'linux-musl.tar.gz' | cut -d '"' -f2)
  NEWRELIC_PATH="https://download.newrelic.com${NEWRELIC_MUSL_PATH}"
  curl -L ${NEWRELIC_PATH} -o ./root/newrelic-musl.tar.gz
  cd /root
  gzip -dc newrelic-musl.tar.gz | tar xf -
  rm newrelic-musl.tar.gz
  NEWRELIC_DIRECTORY=/root/$(basename $(find . -maxdepth 1 -type d -name newrelic\*))
  cd $NEWRELIC_DIRECTORY
  echo "\n" | ./newrelic-install install
  chown root:root $NEWRELIC_DIRECTORY/agent/x64/newrelic-${PHP_ENGINE_VERSION}.so
  mv $NEWRELIC_DIRECTORY/agent/x64/newrelic-${PHP_ENGINE_VERSION}.so /usr/lib/php7/modules/newrelic.so
  rm -rf $NEWRELIC_DIRECTORY/agent/x64
  # Fix permissions on extracted folder
  chown -R $NOT_ROOT_USER:$NOT_ROOT_USER *
  exit 0
fi

echo "[newrelic] arm64 detected, compiling from source"
cd /root
git clone https://github.com/newrelic/newrelic-php-agent
cd newrelic-php-agent

# Assumes apt cache is available, build-essential and phpXX-dev packages are already installed
apk add --no-cache --virtual .newrelic_deps \
  openssl-dev \
  pcre-dev  \
  zlib-dev \
  zlib-static \
  curl-dev \
  automake \
  libtool \
  make

make all

mkdir -p /var/log/newrelic
chmod 777 /var/log/newrelic
cp agent/scripts/newrelic.ini.template "${CONF_PHPMODS}"/newrelic.ini
cp -a bin/daemon /usr/bin/newrelic-daemon

# Cleanup script-specific packages
apk del .newrelic_deps
