#!/usr/bin/env bash

block="# Cluster server
# cluster information configuration

upstream $1 {
		${2}
}
server {
  listen       80;
  server_name  $1;
  # root         /usr/share/nginx/html;

  # Load configuration files for the default server block.
  include /etc/nginx/default.d/*.conf;

  location / {
    proxy_pass http://$1;
    proxy_redirect default;
  }

  error_page 404 /404.html;
  location = /40x.html {
  }

  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
  }
}
"
echo "$block" > "/etc/nginx/sites-available/$1.conf"

sudo systemctl restart nginx