#!/bin/bash
apt-get autoclean
apt-get autoremove

rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
