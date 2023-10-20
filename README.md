# gProject 2: Private Key Infrastructure

## Docker Compose

The compose file consist of two components: the Certificate Authority and the Domain Name Server. Both containers use a Docker volume to store their data.

### Environment variables

All the environment variables who needs te be changed are present in the `env.sample` file.

> [!warning] Do not change any environment variable in de docker compose file. If you do so, the automation scripts will break. My script and compose file are fragile :)

Below a brief description of both the environment variables

- PKI_DOMAIN_NAME: this is the domain name for your PKI. Both the dns and the ca will use this environment variable to create their "environment" <- quality docs right here
  The names of the containers also use this variable. This is necessary to create a consistent automation flow.
- EXTRA_ALLOWED_INCOMING_NAMES: this is a list of all the different domain names your where the CA will accept requests from. The `ca.$PKI_DOMAIN_NAME` is standard included in the file for compatibility reasons.

Please create an `.env` file and fill in your desired values.

## Booting up the beauty

The start our PKI environment, we first need to launch the docker compose file. This can be done with the following command: `docker compose up`. Execute this command in the folder where the `docker-compose.yml` is located.

> [!warning] **You** are responsible for keeping all the secrets safely. At the first boot of your environment, the ca will show you the administrator pass.
> ![](images/CA_password.png)

When the environment is up and running, it is time to configure the DNS-server. Just run the following script with this command: `./configure_dns.sh`. Again, run this command in the folder where this script is located.

The following actions will happen:

1. The .env file gets loaded into the script.
2. The script will wait for the DNS container if it's not already up
3. When the container is up, the `setup_dns.sh` gets activated inside the container of the DNS to setup all the init actions. The following things wil happen:
   1. The necessary packages will be installed
   2. Small-step ca client gets installed in the container environment
   3. A certificate will be requested at the CA (because both containers run in the same docker environment. Name resolution is not a problem.)
   4. The certificate gets converted to a .pfx file. The DNS only accepts this format.
   5. A random password gets generated and de default "admin" password will be overwritten.
   6. A big requests goes to the domain name to set up a initial state. With some predefined settings
   7. Finally the password for the container will be showed to the user.
4. After the setup of the DNS, the `resolve.conf` file of the CA gets changes, so it uses the freshly configured DNS server as resolver during ACME.
5. _The end_

> [!warning] Again, keep the password of the dns server somewhere safe. This script doesn't work when the default admin pass is not present. You cannot run this a second time to "reset" your pass !
> ![](images/DNS_password.png)

### Finalize the DNS server

Now go into the dns interface on ``http://ip:8081``because you need to create a new zone inside the 'Zones' tab, the name of the zone should be the value of `$PKI_DOMAIN_NAME.`

We ask you to do this manually because we think this is a task that should be performed by the administrator of the PKI.

## Prepare clients

Before you can requests certificates, you first need to make the CA's domain name known to your host. This can be done by using the DNS server (if this server contains a record of the CA.) Otherwise you can add the IP of the CA manually in your `/etc/hosts`.

You can also make your machine point to your dns server (resolve.conf or nmtui,..) and then add an A record of the CA to your dns server.

Keep in mind that you need to add "ca." before your (`$PKI_DOMAIN_NAME`) when adding it to your `/etc/hosts`, aswell as you need to specify 127.0.0.1 as the IP address.

## Installing certificates

To install the certificate of the Certificate Authority. You can run one of the two `install_certs` scripts. With the following command: `./install_certs.sh`

In both scripts the following actions will run:

1. The .env file gets loaded into the script.
2. The certificate of the root will be downloaded
3. The certificate gets installed into your default trust store

> [!note] You can uninstall the cert with the following commando: `step certificate uninstall ./root_ca.crt`

## Requesting domains for the webservers

Your dns will need an A record so it can find the webserver. Using the dns interface on ``http://ip:8081``u can go into the zone that you created earlier, here make an A record according to your webserver (webserver name + IP + TTL)

something something

You're going to need to generate the certificate but I AM NOT CAPABLE L

## Team Members

- Jasper Van Meel
- Dante Requena
- Kelvin Bogaerts
- Niels Van De Ginste
- Tom Goedemé
