#!/bin/sh

export DOMAIN=com.bakkle
export PRIVATE_KEY_FILE=bakkle.key
export CERT=7c9ad7ea171d75dd.crt
export CERT_CHAIN=gd_bundle-g2-g1.crt
mkdir tmp

# Strip password from private-key
openssl rsa -in $PRIVATE_KEY_FILE -out tmp/$DOMAIN.key 
# Extract only cert & cert chain from PFX bundle
cat $CERT $CERT_CHAIN >> tmp/$DOMAIN.pem

# Gather useful files for distribution
rm -rf ../etc/ssl/$DOMAIN
mkdir ../etc/ssl/$DOMAIN
cp tmp/$DOMAIN.pem ../etc/ssl/$DOMAIN
cp tmp/$DOMAIN.key ../etc/ssl/$DOMAIN

# Delete working files
rm -rf tmp

