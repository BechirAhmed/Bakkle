#!/bin/sh

echo "Backing up Database"


sudo mkdir /archives/
export DTE=`date +'%Y-%m-%d_%H%M%S'`
sudo mkdir /archives/db
PGPASSWORD=Bakkle123 pg_dump -h bakkle.cw8vja43bda8.us-west-2.rds.amazonaws.com --user root bakkle | gzip > /archives/db/bakkle_db_$DTE.gz
sudo du -sh /archives/db/bakkle_db_$DTE.gz
