#!/bin/bash -e

for extension in "$@"; do
  pecl install "${extension}"
  echo "extension=${extension}.so" > "${CONF_PHPMODS}"/"${extension}".ini
done

