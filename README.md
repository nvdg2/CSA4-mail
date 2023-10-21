# IIS Server using HTTPS - Introduction

This is a readme that contains the steps in order to make IIS work using StepCA. There's two ways of achieving it: one will require a lot of manual effort using GUI and no docker containers, the other way will be using powershell scripts and automation in containers.

In this guide, you will mostly find how to setup the system using the first approach. I'm still working on how to automate everything using containers.

Read this manual carefully. One missing step and nothing will work as expected.

# Docker - Docker Compose & IIS op Windows Server 2022

### Used Links & Guides:

[https://learn.microsoft.com/en-us/iis/get-started/getting-started-with-iis/getting-started-with-the-iis-manager-in-iis-7-and-iis-8]

[https://smallstep.com/docs/]

[https://www.virtualizationhowto.com/2022/09/install-docker-on-windows-server-2022/](https://www.virtualizationhowto.com/2022/09/install-docker-on-windows-server-2022/)

[https://cloudinfrastructureservices.co.uk/how-to-install-docker-compose-on-windows-server-2016-2019-2022/](https://cloudinfrastructureservices.co.uk/how-to-install-docker-compose-on-windows-server-2016-2019-2022/)

[https://hub.docker.com/_/microsoft-windows-servercore-iis](https://hub.docker.com/_/microsoft-windows-servercore-iis)

# Requirements

- A windows server 2022 using a VM. For this example, a NAT network using VMWare Workstation Pro is used.

- The PKI system: StepCA installation on another VM using a container, with a distro of choice. Files can be found in this repo.

- DNS server: Another container running on the same machine as the StepCA.

- A simple testing html web page, located in the windows server under C:\inetpubb\wwwroot
# Installation Guide - Manual

In your Windows environment, go to server manager. Click on manage at the upper right corner of the window. Select add roles and features. Select the current server from the pool and check the server role called Web Server (IIS).

This should install IIS on the system. A reboot may be required, and it's not a bad idea to do so either.

The next step is to test if the web page is reachable. If you can see the test page, you can start setting up SSL.

The first thing you want to do is set the hostfile of your windows system. You can do so by manually adding the necessary editing the hosts file or you can adjust the set_hostsfile script to use the IP and domain that you want, then run it. Make sure to do this, as the other steps will not work if you don't.

You should also set the DNS settings of your windows server to the address of the DNS server that's running on your other machine in a container.

Now, you need to set up the root certificate in the windows server in order to 'trust' the CA. You can do this manually, or using a script I made that you can also find next to this readme file. It's called install-rootcert. Note that using this script will require a .env file, which needs to be located in the same directory as the script itself.

The variable needed in this file is PKI_DOMAIN_NAME. Which is in our case ca.$PKI_DOMAIN_NAME. Run the script, and wait for it to complete.

Create a signed certificate using the step commands. You can do so by using step cli, which you can install as a frontend to communicate with the step ca system/container. I created the certificate on the CA server itself, for testing purposes. 

**Example command here:**

    step certificate create example.com example.com.crt example.com.key --profile leaf --not-after=8760h --ca ./intermediate_ca.crt --ca-key ./intermediate_ca.key --bundle

If done correctly, you should now have two created files: a crt and a key. In order for IIS to work, you need a pfx certificate. This can be created easily using openssl for example.

**IMPORTANT:** all the certificates used in the chain need to be used using this openssl command. If one of them isn't included, IIS wil throw errors and warnings at you.

**With OpenSSL installed, use this command:**

`openssl pkcs12 -export -out combined.pfx -inkey your.key -in your.crt -certfile intermediate.crt` 
^ Depending on the key you used to make the crt. Could be root, or intermediate.

This should now merge the files into one, called combined.pfx for example. This certificate can now be used to setup SSL in the IIS manager.

There's countless of good tutorials on how to set this up. But overall, the process goes as followed:

- Open IIS manager by typing it in windows search.

- Click on your hostname on the left pane, then select 'Server Certificates'.

- In the right pane, click on import. Select the pfx file that you created earlier and fill in the password box. Certificate store should be Web Hosting, but personal will also work.

- Go to Sites in the left pane -> Your site name. Then select bindings in the right pane. You should be able to add the certificate to a hostname. Selct https, as IP address select All Unassigned and as port 443. Make sure to select the SSL certificate as well.

- When done, restart the website using the button under Manage Website.

## Optional - Setting up Docker & Docker Compose on Windows Server

### Steps to install Docker:

Install Windows Server 2022 in a VM. If you're using a previous version, a manual installation of WSL will be required.

The following steps are necessary in order to get docker to work:

- Configure the VM to use nested virtualization in CPU settings.

- In server manager, open the roles and features and make sure to check 'Containers'. Then press next. Now you will be able to select roles. Set Hyper-V to enabled.

- Reboot the VM

- Use the following commands.

Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1

.\install-docker-ce.ps1

Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

Install-Package -Name docker -ProviderName DockerMsftProvider

### Creating Dockerfile:

FROM mcr.microsoft.com/windows/servercore/iis

RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

WORKDIR /inetpub/wwwroot

COPY content/ .

docker build -t iis-site .

docker run -d -p 80:80 -p 443:443 --name my-running-site iis-site

### Install Docker-Compose:

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

cd C:\Program Files\Docker>

Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile docker-compose.exe