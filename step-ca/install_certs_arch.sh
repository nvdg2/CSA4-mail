#!/bin/bash
set -o allexport
source .env
set +o allexport

curl -k "https://ca.$PKI_DOMAIN_NAME:9000/roots.pem" > root_ca.crt
fingerprint=$(step-cli certificate fingerprint ./root_ca.crt)
step-cli ca bootstrap --ca-url https://ca.$PKI_DOMAIN_NAME:9000 --fingerprint $fingerprint --install