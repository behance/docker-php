#!/bin/bash

# Perform cleanup, ensure unnecessary packages are removed
RUN apt-get remove -yq \
        wget \
        git \
        php5-dev \
        gcc && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    rm -rf /tmp/* /var/tmp/*
