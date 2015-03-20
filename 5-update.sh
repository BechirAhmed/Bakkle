#!/bin/sh

# WARNING THIS IS DESTRUCTIVE
sudo rm -rf            /bakkle/www

sudo mkdir -m 755      /bakkle
sudo mkdir -m 755      /bakkle/www
sudo mkdir -m 755      /bakkle/www/static

sudo cp www/static/*   /bakkle/www/static/
sudo chown -R www-data /bakkle/www 

sudo service nginx restart
sudo service bakkle restart

