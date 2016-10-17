#!/bin/bash

if [[ $SERVER_FASTCGI_BUFFERS ]]
then
  echo "[nginx-fastcgi] setting fastcgi_buffers ${SERVER_FASTCGI_BUFFERS}"
  sed -i "s/\fastcgi_buffers .*;/fastcgi_buffers ${SERVER_FASTCGI_BUFFERS};/" $CONF_NGINX_SITE
fi

if [[ $SERVER_FASTCGI_BUFFER_SIZE ]]
then
  echo "[nginx-fastcgi] setting fastcgi_buffer_size ${SERVER_FASTCGI_BUFFER_SIZE}"
  sed -i "s/\fastcgi_buffer_size .*;/fastcgi_buffer_size ${SERVER_FASTCGI_BUFFER_SIZE};/" $CONF_NGINX_SITE
fi

if [[ $SERVER_FASTCGI_BUSY_BUFFERS_SIZE ]]
then
  echo "[nginx-fastcgi] setting fastcgi_busy_buffers_size ${SERVER_FASTCGI_BUSY_BUFFERS_SIZE}"
  sed -i "s/\fastcgi_busy_buffers_size .*;/fastcgi_busy_buffers_size ${SERVER_FASTCGI_BUSY_BUFFERS_SIZE};/" $CONF_NGINX_SITE
fi
