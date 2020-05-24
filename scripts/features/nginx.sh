#!/usr/bin/env bash

# Check If Nginx Has Been Installed

if [ -f /home/vagrant/.homestead-features/nginx ]
then
    echo "Nginx already Started."
    exit 0
fi

mkdir -p /home/vagrant/.homestead-features

touch /home/vagrant/.homestead-features/nginx

chown -Rf vagrant:vagrant /home/vagrant/.homestead-features

# Start Nginx
sudo systemctl enable nginx

sudo systemctl start nginx

echo "Nginx Start complete"

sudo firewall-cmd --permanent --add-service=http

sudo firewall-cmd --permanent --add-service=https

sudo systemctl restart firewalld

echo "firewall Start complete"

# sudo su

# mkdir /etc/nginx/sites-available

# this is to replace the content with 48 lines
# sed -i "48s proxy_pass http://www.cluster.com;" /etc/nginx/nginx.conf
# this is adding content to line 48
# sed -i "48i proxy_pass http://www.cluster.com;" /etc/nginx/nginx.conf
# sed -i "58i include /etc/nginx/sites-available/*.conf;" /etc/nginx/nginx.conf

# exit