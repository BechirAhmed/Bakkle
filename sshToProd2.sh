#!/bin/sh

chmod 400 keys/Bakkle1AWSKeyPair.pem

ssh -i keys/Bakkle1AWSKeyPair.pem ubuntu@ec2-52-25-104-231.us-west-2.compute.amazonaws.com -A
