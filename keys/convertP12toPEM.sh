#!/bin/sh
# Converts a p12 file exported from keychain containing
# an APN certificate + key into the PEM file needed
# for APN push code.
# I used password=bakkle (Sandor)

for I in *.p12; do
openssl pkcs12 -in $I -out $I.pem -nodes -clcerts
done

