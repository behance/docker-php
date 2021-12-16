#!/bin/bash

ARCH=$(archstring --x64 x64 --arm64 arm64)

if [[ "$ARCH" == "x64" ]]; then
  echo "[newrelic] x64 detected, installing pre-built packages"

  echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list
  wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -

  # Prevent newrelic install from prompting for input
  echo newrelic-php5 newrelic-php5/application-name string "REPLACE_NEWRELIC_APP" | debconf-set-selections
  echo newrelic-php5 newrelic-php5/license-key string "REPLACE_NEWRELIC_LICENSE" | debconf-set-selections

  apt-get update
  apt-get install -yqq \
      newrelic-php5 \
      newrelic-php5-common \
      newrelic-daemon

  # Removes unused agents for other PHP versions
  cd /usr/lib/newrelic-php5/agent/x64 && ls | grep -v newrelic-${PHP_ENGINE_VERSION}.so | xargs rm && \
  exit 0
fi

echo "[newrelic] arm64 detected, compiling from source"
cd /root
git clone https://github.com/newrelic/newrelic-php-agent

# Assumes apt cache is available, build-essential and phpXX-dev packages are already installed
apt-get install -yqq \
  libssl-dev \
  libpcre3-dev \
  golang

make all

mkdir -p /var/log/newrelic
chmod 777 /var/log/newrelic
cp agent/scripts/newrelic.ini.template "${CONF_PHPMODS}"/newrelic.ini
cp bin/daemon /usr/bin/newrelic-daemon

# Cleanup script-specific packages
apt-get remove --purge -yq \
  libssl-dev \
  libpcre3-dev \
  golang
