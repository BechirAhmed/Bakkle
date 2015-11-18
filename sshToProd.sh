#!/bin/sh

chmod 400 keys/Bakkle1AWSKeyPair.pem

ssh -i keys/Bakkle1AWSKeyPair.pem ubuntu@54.148.185.10 -A
