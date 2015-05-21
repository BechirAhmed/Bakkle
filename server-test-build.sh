#!/bin/bash

# The location of this script
DIR="$( cd "$( dirname "$0" )" && pwd )" 

# The address of the remote machine
address=rhv-bakkle-bld.rhventures.org
# Username used for remote build
user=bkbuild
# Auth key for remote access
key=keys/bkbuild
# Root directory of web modules on remote machine
webRoot=/omnisite-bakkle

# Root directory for website file backups
backups=/backups

sshCommand="ssh $address -l bkbuild -i $key"
scpCommand="scp -r -i $key"

echo "###Kick up Test Server"
# eval sudo $scpCommand ${DIR} $user@$address:/
chmod 600 keys/bkbuild
echo
echo $sshCommand $webRoot/97-git-pull.sh
echo
eval $sshCommand $webRoot/97-git-pull.sh

echo
echo $sshCommand $webRoot/1-system-deps.sh
echo
eval $sshCommand $webRoot/1-system-deps.sh

echo
echo $sshCommand $webRoot/2-webserver.sh
echo
eval $sshCommand $webRoot/2-webserver.sh

echo
echo $sshCommand $webRoot/3-webapp-deps.sh
echo
eval $sshCommand $webRoot/3-webapp-deps.sh

echo
echo $sshCommand $webRoot/5-update.sh
echo
eval $sshCommand $webRoot/5-update.sh
echo "### Server End - Sleep for 5 seconds during reboot"

eval sleep 5

echo "### Server Test Started"
echo
echo $sshCommand $webRoot/testScript.py
echo
eval $sshCommand $webRoot/testScript.py
echo "### Test End"