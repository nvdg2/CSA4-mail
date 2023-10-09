# Docker - Docker Compose & IIS op Windows Server 2022

### Gebruikte Links:

[https://www.virtualizationhowto.com/2022/09/install-docker-on-windows-server-2022/](https://www.virtualizationhowto.com/2022/09/install-docker-on-windows-server-2022/)

[https://cloudinfrastructureservices.co.uk/how-to-install-docker-compose-on-windows-server-2016-2019-2022/](https://cloudinfrastructureservices.co.uk/how-to-install-docker-compose-on-windows-server-2016-2019-2022/)

[https://hub.docker.com/_/microsoft-windows-servercore-iis](https://hub.docker.com/_/microsoft-windows-servercore-iis)



### Stappen:

Installeer Windows Server 2022 in een VM -> Vorige versies vereisen manuele installatie van WSL.

Volgende stappen zijn nodig om docker draaiend te krijgen:

 - VM instellen op Nested Virtualization in CPU settings.
 - In server manager, open roles en features. Vink ‘Containers’ aan bij
   Features. Bij Server Roles vink je ‘Hyper-V’ aan.
 - Reboot de VM
 - Gebruik onderstaande commando’s

Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1  
.\install-docker-ce.ps1

Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

Install-Package -Name docker -ProviderName DockerMsftProvider


### Dockerfile aanmaken:

FROM mcr.microsoft.com/windows/servercore/iis

RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

WORKDIR /inetpub/wwwroot

COPY content/ .


docker build -t iis-site .
docker run -d -p 8000:80 --name my-running-site iis-site

# Optioneel

### Docker compose installeren:

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

cd C:\Program Files\Docker>

Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile docker-compose.exe
