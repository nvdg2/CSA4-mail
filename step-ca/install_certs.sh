#!/bin/bash
set -o allexport
source .env
set +o allexport

step_command=""

if command -v step &> /dev/null; then
    step_command=step
elif command -v step-cli &> /dev/null; then
    step_command=step-cli
else
    echo "Step CLI is niet geïnstalleerd. Installeer Step CLI en voer de gewenste acties uit."
    exit 1
fi

curl -k "https://ca.$PKI_DOMAIN_NAME:9000/roots.pem" > root_ca.crt
fingerprint=$($step_command certificate fingerprint ./root_ca.crt)
$step_command ca bootstrap --ca-url https://ca.$PKI_DOMAIN_NAME:9000 --fingerprint $fingerprint --install
