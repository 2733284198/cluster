#!/usr/bin/env bash

# Check If Apache Has Been Installed
if [ -f /home/vagrant/.homestead-features/apache ]
then
    echo "Apache already Started."
    exit 0
fi

mkdir -p /home/vagrant/.homestead-features

touch /home/vagrant/.homestead-features/apache

chown -Rf vagrant:vagrant /home/vagrant/.homestead-features

# Start Apache
sudo systemctl enable httpd

sudo systemctl start httpd

sudo ln -s /var/www/html/code/ /home/vagrant

echo "Apache Start complete"

# Start php-fpm
sudo systemctl enable php-fpm

sudo systemctl start php-fpm

echo "PHP Start complete"

sudo firewall-cmd --permanent --add-service=http

sudo firewall-cmd --permanent --add-service=https

sudo systemctl restart firewalld

echo "firewall Start complete"