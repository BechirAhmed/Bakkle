#!/bin/bash

# WARNING THIS IS DESTRUCTIVE
sudo service bakkle stop
#sudo rm -rf              /bakkle/www
sudo mkdir /archives/
export DTE=`date +'%Y-%m-%d_%H%M%S'`
sudo mkdir /archives/$DTE
sudo cp -r /bakkle /archives/$DTE

sudo mkdir -m 755        /bakkle
sudo mkdir -m 755        /bakkle/run
sudo mkdir -m 755        /bakkle/www
sudo mkdir -m 755        /bakkle/www/p1
sudo mkdir -m 755        /bakkle/www/static

sudo cp -r www/*         /bakkle/www/
sudo cp -r www/p1/*      /bakkle/www/p1/
sudo cp -r www/static/*  /bakkle/www/static/
sudo chown -R www-data   /bakkle/www 

sudo mkdir -m 755        /bakkle/log

# software version
sudo touch /bakkle/www/bakkle/version.py
sudo chmod 777 /bakkle/www/bakkle/version.py
sudo echo bakkle_server_version = \"`git rev-parse HEAD` --  `git describe --long`\" >> /bakkle/www/bakkle/version.py

pushd /bakkle/www/bakkle
sudo python manage.py makemigrations
sudo python manage.py migrate
popd

# system service script
sudo install -m 755      ./etc/init.d/bakkle /etc/init.d/bakkle
sudo update-rc.d bakkle defaults
sudo service bakkle start
