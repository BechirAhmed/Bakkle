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
# eval $sshCommand ssh-agent bash -c 'ssh-add ./ext-bakkle.key'
# eval $sshCommand ssh-agent bash -c 'git checkout jenkins-test'
# eval $sshCommand ssh-add ./ext-bakkle.key
# eval $sshCommand git checkout jenkins-test
# eval $sshCommand git checkout jenkins-test
eval $sshCommand $webRoot/97-git-pull.sh
eval $sshCommand $webRoot/1-system-deps.sh
eval $sshCommand $webRoot/2-webserver.sh
eval $sshCommand $webRoot/3-webapp-deps.sh
eval $sshCommand $webRoot/5-update.sh
echo "### Server End"
echo "### Server Test"
eval $sshCommand $webRoot/testScript.py
echo "### Test End"