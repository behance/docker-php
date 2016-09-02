#!/bin/bash
# IMPORTANT: This script has to be called *manually* by a child implementing this repo as a parent

# apt-mark showauto  for any additional packages that can be cleaned up

# Perform cleanup, ensure unnecessary packages are removed
apt-get remove --purge -yq \
    wget \
    php7.0-dev \
    gcc \
    libgcc-4.8-dev \
    cpp-4.8 \
    dpkg-dev \
    manpages \
    manpages-dev \
    man-db \
    libpcre3-dev \
    patch \
    make \
    unattended-upgrades \
    software-properties-common \
    && \
apt-get autoclean -y && \
apt-get autoremove -y && \
rm -rf /var/lib/{cache,log}/ && \
rm -rf /var/lib/apt/lists/ && \
rm -rf /var/tmp/*
