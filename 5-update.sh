#!/bin/sh

# WARNING THIS IS DESTRUCTIVE
sudo rm -rf              /bakkle/www

sudo mkdir -m 755        /bakkle
sudo mkdir -m 755        /bakkle/run
sudo mkdir -m 755        /bakkle/www
sudo mkdir -m 755        /bakkle/www/static

sudo cp -r www/*         /bakkle/www/
sudo cp -r www/static/*  /bakkle/www/static/
sudo chown -R www-data   /bakkle/www 

sudo service bakkle restart

