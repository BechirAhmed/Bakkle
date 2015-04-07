#!/bin/sh

cd /home/ubuntu/omnisite-bakkle
ssh-agent bash -c 'ssh-add /etc/ext-bakkle.key; git pull'
./5-update.sh

