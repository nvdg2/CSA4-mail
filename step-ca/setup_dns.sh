#!/bin/bash
apt update
apt install wget
wget https://dl.smallstep.com/gh-release/cli/gh-release-header/v0.25.0/step-cli_0.25.0_amd64.deb
dpkg -i step-cli_0.25.0_amd64.deb
mkdir certs
cd certs
wget http://certs.pki.project:8080/root_ca.crt
step ca certificate dns.pki.project key.pem cert.pem -provisioner acme --ca-url https://ca.pki.project:9000 --root ./root_ca.crt
openssl pkcs12 -export -out cert.pfx -inkey cert.pem -in key.pem -passout pass: