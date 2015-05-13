#!/bin/sh

sudo apt-get install python-django python-pip python2.7-dev
sudo pip install uwsgi
sudo pip install apns
sudo pip install boto

#probably needed on ubuntus udo apt-get install libffi-dev libssl-dev
sudo pip install requests[security]
sudo pip install django --upgrade

