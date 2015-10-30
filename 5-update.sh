#!/bin/bash

# WARNING THIS IS DESTRUCTIVE
sudo service bakkle stop
sudo service bakkle-ws stop
#sudo rm -rf              /bakkle/www
sudo mkdir /archives/
export DTE=`date +'%Y-%m-%d_%H%M%S'`
sudo mkdir /archives/$DTE
sudo cp -r /bakkle /archives/$DTE
rm -rf /bakkle/www/bakkle/*/migrations

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

DATABASE=dev
if [ `hostname` == 'ip-172-31-21-18' ]; then
   DATABASE=production
fi
if [ `hostname` == 'ip-172-31-27-192' ]; then
   DATABASE=production
fi
if [ `hostname` == 'rhv-bakkle' ]; then
   DATABASE=testdb
fi
if [ `hostname` == 'rhv-bakkle-bld' ]; then
   DATABASE=dev
fi

echo Updating database: $DATABASE
pushd /bakkle/www/bakkle
sudo python manage.py makemigrations
sudo python manage.py migrate --database=$DATABASE
popd

BAKKLE_LOG_FILE=/bakkle/log/bakkle.log
if [ ! -e "$BAKKLE_LOG_FILE" ]; then
	sudo touch $BAKKLE_LOG_FILE
fi

# system service script
# sudo install -m 755      ./etc/init.d/bakkle /etc/init.d/bakkle
# sudo update-rc.d bakkle defaults
# sudo service bakkle start

sudo rm -f /etc/init.d/bakkle*

sudo install -m 755      ./etc/init.d/bakkle /etc/init.d/bakkle
sudo update-rc.d bakkle defaults
sudo service bakkle start
#sudo tail -f $BAKKLE_LOG_FILE
