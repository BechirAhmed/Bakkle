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
webRoot=/bakkle
# Location of database scripts on remote machine
scripts=/bakkle

# Root directory for website file backups
backups=/backups

sshCommand="ssh $address -l bkbuild -i $key"
scpCommand="scp -r -i $key"

echo "### Copy Files to Test Server"
#eval $scpCommand $key ${DIR} $user@$address:$webRoot
eval $sshCommand . $webRoot/omnisite-bakkle/1-system-deps.sh
echo "### End Test";