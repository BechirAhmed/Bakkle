#!/bin/bash

# The location of this script
DIR="$( cd "$( dirname "$0" )" && pwd )" 

# The address of the remote machine
address=rhv-bakkle-bld.rhventures.org
# Username used for remote build
user=bkbuild
# Auth key for remote access
key=${DIR}/keys/bkbuild
# Root directory of web modules on remote machine
webRoot=/omnisite-bakkle

# Root directory for website file backups
backups=/backups

sshCommand="ssh $address -l bkbuild -i $key"
scpCommand="scp -r -i $key"

echo "###Kick up Test Server"
# eval sudo $scpCommand ${DIR} $user@$address:/
echo $sshCommand sudo ssh-agent bash -c 'cd omnisite-bakkle;./98-update-bkbuild.sh'
eval $sshCommand sudo ssh-agent bash -c 'cd omnisite-bakkle;./98-update-bkbuild.sh'
echo "### Server End"
echo "\r\n"
echo "### Server Test"
echo $sshCommand sudo ssh-agent bash -c 'cd omnisite-bakkle;./testScript.py'
eval $sshCommand sudo ssh-agent bash -c 'cd omnisite-bakkle;./testScript.py'
echo "### Test End"