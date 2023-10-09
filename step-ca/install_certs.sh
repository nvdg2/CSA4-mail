#!/bin/bash


fingerprint=$(docker exec step-ca step certificate fingerprint certs/root_ca.crt)
step-cli ca bootstrap --ca-url https://ca.internal:9000 --fingerprint $fingerprint --install