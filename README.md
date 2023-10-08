# Project 2: Private Key Infrastructure

## Installing PKI

### Docker Compose Explanation

In the `step-ca` folder, you can find a Docker Compose file with some important values defined:

- We are using the `smallstep/step-ca:latest` image.
- The CA will run on port 9000.
- Docker volume `step` is used as storage, mapping to the `/home/step` folder.

The above values only need to be modified if desired.

There are also some environment variables defined in the .env.bak file:

- CA_NAME (default: `default_CA_name`)
- ALLOWED_INCOMING_NAMES (default: `localhost`)
- CA_PASSWORD (default: `CHANGE_ME_PLEASE`)
- ALLOW_REMOTE_MANAGEMENT (default: `true`)

## Team Members

- Jasper Van Meel
- Dante Requena
- Kelvin Bogaerts
- Niels Van De Ginste
- Tom Goedemé