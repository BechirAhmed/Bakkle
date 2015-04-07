#!/bin/sh

cd /home/ubuntu/omnisite-bakkle
sudo ssh-agent bash -c 'ssh-add /etc/ext-bakkle.key; git pull'
sudo ./5-update.sh

