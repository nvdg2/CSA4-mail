# Project 2: Private Key Infrastructure

## PKI

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

> Your CA will initialize and create the necessary certificates for the root.

### Configuring client

To configure the client, you will need to install `step`. This is the command line interface that will be used to communicate with the CA.  
For more info, you can vist the following [link](https://smallstep.com/docs/step-cli/reference/).

To configure your root certificate on a client, use the following steps:

- `step certificate fingerprint <path to certificate>` -> get the fingerprint of the certificate
  - Using the path to the `root_ca.crt` file will give the fingerprint of the CA
- `step ca bootstrap --ca-url https://localhost:9000/ --fingerprint 319[...]f3 --install` -> download the CA's root certificate to `$STEPPATH/certs/root_ca.crt`
  - After this, commands no longer need the to specify the `--ca-url`, `--root` or `--fingerprint` flags
  - This command also create a configuration file in `$STEPPATH/configs/defaults.json` with the CA url, root certificate location & its fingerprint
- `step ca certificate example.com cert.pem key.pem --ca-url=https://localhost:9000/` -> request a certificate for example.com & save the resulting cert and key in `cert.pem` and `key.pem` respectively

WIP

- `step ca init` -> initialize the CA PKI
  - By default, the config goes to `$STEPPATH`, which is usually `~/.step` (another application that doesn't respect the XDG base directory specification...)

## Configuring the PKI V2

### Installation of CA

Fot the installation of the CA, we are using a standalone docker container. This is because we were having problems with the docker compose version of our CA.

To setup the container, run the following script: `create-ca.sh`. This script will create the container and a folder which the container has access to to store its data.

### Copy the root CA to a central location

Everyone who wants an certificate, needs the certificate of the root CA. The location of this certificate will be used in the next command (IDK why but it was required to the step command working).

Here is an example command which can be used to copy the root ca: `scp [USER]@[IP]:[LOCATION OF CONTAINER_DATA]/step-ca-data/certs/root_ca.crt ~/root_ca.crt`

### Generate certificates for domains

Use the following command to issue a certificate for a certain domain: `step ca certificate --provisioner acme [YOUR_DOMAIN_NAME] cert.pem key.pem --root [LOCATION_OF_ROOT_CA] --ca-url https://ca.internal:9000`

> The root translates the dns name to an ip address. This means that the container needs to have a mapping of the ip and the requested domain.
Keep also in mind that port 80 needs to accept incoming requests. The firewall blocks this port by default.


## Team Members

- Jasper Van Meel
- Dante Requena
- Kelvin Bogaerts
- Niels Van De Ginste
- Tom Goedemé
