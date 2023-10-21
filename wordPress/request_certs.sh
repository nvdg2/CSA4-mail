#!/bin/bash

curl -k https://ca.$PKI_DOMAIN_NAME:9000/roots.pem > /home/step/roots.pem
step ca certificate --root=/home/step/roots.pem --provisioner=acme --http-listen=0.0.0.0:80 --ca-url=https://ca.$PKI_DOMAIN_NAME:9000/ $DOMAIN /home/step/cert.pem /home/step/key.pem
ls /home/step
cat key.pem