#!/usr/bin/env bash

block="<VirtualHost *:$3>
    ServerAdmin webmaster@localhost
    ServerName $1
    ServerAlias www.$1
    DocumentRoot "$2"

    ErrorLog /var/log/httpd/$1-error.log
    CustomLog /var/log/httpd/$1-access.log combined

    <Directory "$2">
        AllowOverride All
        Require all granted
    </Directory>

</VirtualHost>
"
echo "$block" > "/etc/httpd/sites-available/$1.conf"

sudo systemctl restart httpd