#!/bin/bash


sudo rm      -rf                                             /etc/ssl/com.bakkle/
sudo mkdir   -m 755                                          /etc/ssl/com.bakkle/
sudo install -m 644 etc/ssl/com.bakkle/com.bakkle.key        /etc/ssl/com.bakkle/
sudo install -m 644 etc/ssl/com.bakkle/com.bakkle.pem        /etc/ssl/com.bakkle/

sudo install -m 644 etc/nginx/sites-available/com.bakkle.app.conf /etc/nginx/sites-available/
sudo install -m 644 etc/nginx/sites-available/com.bakkle.testcluster.conf /etc/nginx/sites-available/
sudo install -m 644 etc/nginx/sites-available/org.rhventures.bakkle.conf /etc/nginx/sites-available/
sudo install -m 644 etc/nginx/sites-available/org.rhventures.bakkle-bld.conf /etc/nginx/sites-available/
sudo install -m 644 etc/nginx/sites-available/org.rhventures.wongb.conf /etc/nginx/sites-available/

sudo apt-get install nginx -y

sudo ./bin/nginx_dissite 000-default
sudo ./bin/nginx_dissite default

if [ `hostname` == 'ip-172-31-21-18' ]; then
   sudo ./bin/nginx_ensite com.bakkle.app.conf
fi
if [ `hostname` == 'ip-172-31-27-192' ]; then
   echo "using testcluster"
   sudo ./bin/nginx_ensite com.bakkle.testcluster.conf
fi
if [ `hostname` == 'rhv-bakkle' ]; then
   sudo ./bin/nginx_ensite org.rhventures.bakkle.conf
fi
if [ `hostname` == 'rhv-bakkle-bld' ]; then
   sudo ./bin/nginx_ensite org.rhventures.bakkle-bld.conf
fi
if [ `hostname` == 'rhv-lnx-291scs' ]; then
   sudo ./bin/nginx_ensite org.rhventures.wongb.conf
fi

sudo service nginx restart
