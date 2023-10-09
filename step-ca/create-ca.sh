#!/bin/bash
mkdir ./step-ca-data
docker run -d --name=step-ca -v ./step-ca-data:/home/step -p 9000:9000 -e DOCKER_STEPCA_INIT_ACME=true -e DOCKER_STEPCA_INIT_NAME="ca-pki-project" -e DOCKER_STEPCA_INIT_DNS_NAMES="ca.internal" --name step-ca smallstep/step-ca

