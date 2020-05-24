#!/usr/bin/env bash

# Check If Database Has Been Installed

if [ -f /home/vagrant/.homestead-features/database ]
then
    echo "Database already Started."
    exit 0
fi

mkdir -p /home/vagrant/.homestead-features

touch /home/vagrant/.homestead-features/database

chown -Rf vagrant:vagrant /home/vagrant/.homestead-features

# Start Mysql
sudo systemctl enable mariadb

sudo systemctl start mariadb

echo "Mysql Start complete"

# Start Redis
sudo systemctl enable redis

sudo systemctl start redis

echo "Redis Start complete"

sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp

sudo firewall-cmd --permanent --zone=public --add-port=6379/tcp

sudo systemctl restart firewalld

echo "Mysql database information: the username is 'cluster' and the password is 'password'"

echo "Redis database information: the username is 'root' and the password is empty"