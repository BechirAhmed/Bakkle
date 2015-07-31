#!/bin/sh

chmod 400 keys/Bakkle1AWSKeyPair.pem

ssh -i keys/Bakkle1AWSKeyPair.pem ubuntu@ec2-54-149-89-82.us-west-2.compute.amazonaws.com -A
