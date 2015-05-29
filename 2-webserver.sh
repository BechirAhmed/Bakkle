#!/bin/bash


sudo rm      -rf                                             /etc/ssl/com.bakkle/
sudo mkdir   -m 755                                          /etc/ssl/com.bakkle/
sudo install -m 644 etc/ssl/com.bakkle/com.bakkle.key        /etc/ssl/com.bakkle/
sudo install -m 644 etc/ssl/com.bakkle/com.bakkle.pem        /etc/ssl/com.bakkle/

sudo install -m 644 etc/nginx/sites-available/com.bakkle.app /etc/nginx/sites-available/
sudo install -m 644 etc/nginx/sites-available/org.rhventures.bakkle /etc/nginx/sites-available/
sudo install -m 644 etc/nginx/sites-available/org.rhventures.bakkle-bld /etc/nginx/sites-available/

sudo apt-get install nginx -y

sudo ./bin/nginx_dissite 000-default
if [ `hostname` == 'ip-172-31-21-18' ]; then
   sudo ./bin/nginx_ensite com.bakkle.app
fi
if [ `hostname` == 'ip-172-31-27-192' ]; then
   sudo ./bin/nginx_ensite com.bakkle.app
fi
if [ `hostname` == 'bakkle' ]; then
   sudo ./bin/nginx_ensite org.rhventures.bakkle
fi
if [ `hostname` == 'rhv-bakkle-bld' ]; then
   sudo ./bin/nginx_ensite org.rhventures.bakkle-bld
fi

sudo service nginx restart
