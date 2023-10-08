# Project 2: Private Key Infrastructure

## Smallstep CA

### Installation - Docker Compose

- In the `step-ca` folder, you can find a Docker Compose file with some important values defined:
    - We are using the `smallstep/step-ca:0.25.0` image.
    - The CA will run on port 9000.
    - Docker volume `step` is used as storage, mapping to the `/home/step` folder.
- There are also some environment variables defined in the `.env.sample` file:
    - `CA_NAME` (default: `default_CA_name`)
    - `ALLOWED_INCOMING_NAMES` (default: `localhost`)
    - `CA_PASSWORD` (default: `CHANGE_ME_PLEASE`)
    - `ALLOW_REMOTE_MANAGEMENT` (default: `true`)
- Copy `.env.sample` to `.env` and modify the values before running `docker compose up -d`

### Smallstep CA

- Step CA -> certificate authority
- Configuration: https://smallstep.com/docs/step-ca/configuration/#overview

### `step-cli`

- `step-cli` -> CLI for Step CA
    - Command reference: https://smallstep.com/docs/step-cli/reference/
- `step ca init` -> initialize the CA PKI
    - By default, the config goes to `$STEPPATH`, which is usually `~/.step` (another application that doesn't respect the XDG base directory specification...)
- `step certificate fingerprint <path to certificate>` -> get the fingerprint of the certificate
    - Using the path to the `root_ca.crt` file will give the fingerprint of the CA
- `step ca bootstrap --ca-url https://localhost:9000/ --fingerprint 319[...]f3 --install` -> download the CA's root certificate to `$STEPPATH/certs/root_ca.crt`
    - After this, commands no longer need the to specify the `--ca-url`, `--root` or `--fingerprint` flags
    - This command also create a configuration file in `$STEPPATH/configs/defaults.json` with the CA url, root certificate location & its fingerprint
- `step ca certificate example.com cert.pem key.pem --ca-url=https://localhost:9000/` -> request a certificate for example.com & save the resulting cert and key in `cert.pem` and `key.pem` respectively

## Team Members

- Jasper Van Meel
- Dante Requena
- Kelvin Bogaerts
- Niels Van De Ginste
- Tom Goedemé