#!/bin/sh

cd "$(dirname "$0")"
eval $(ssh-agent -s)
eval ssh-add ext-bakkle.key
eval git pull
