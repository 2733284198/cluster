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