#!/bin/sh

#cd /home/ubuntu/omnisite-bakkle
sudo ssh-agent bash -c 'ssh-add ./ext-bakkle.key; git pull'
sudo ./1-system-deps.sh
sudo ./2-webserver.sh
sudo ./3-webapp-deps.sh
sudo ./5-update.sh

