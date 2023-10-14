#!/bin/bash
if ! command -v wget &> /dev/null || ! command -v curl &> /dev/null
then
    apt update
    apt install wget curl -y

    wget https://dl.smallstep.com/gh-release/cli/gh-release-header/v0.25.0/step-cli_0.25.0_amd64.deb
    dpkg -i step-cli_0.25.0_amd64.deb

    mkdir certs
    cd certs
    wget http://certs.pki.project:8080/root_ca.crt
    step ca certificate dns.pki.project key.pem cert.pem -provisioner acme --ca-url https://ca.pki.project:9000 --root ./root_ca.crt
    openssl pkcs12 -export -out cert.pfx -inkey cert.pem -in key.pem -passout pass:

    # Genereer een willekeurig wachtwoord van 12 tekens
    random_password=$(openssl rand -base64 12)

    # Gegeven JSON-tekst
    json=$(curl "http://localhost:8081/api/user/login?user=admin&pass=admin&includeInfo=true")
    token_value=$(echo $json | grep -o '"token":"[^"]*"' | awk -F '"' '{print $4}')
    
    curl "http://localhost:8081/api/user/changePassword?token=$token_value&pass=$random_password"
    curl "http://localhost:8081/api/settings/set?token=$token_value&dnsServerDomain=pki.project&dnsServerLocalEndPoints=0.0.0.0%3A53%2C%5B%3A%3A%5D%3A53&defaultRecordTtl=3600&dnsAppsEnableAutomaticUpdate=true&preferIPv6=false&udpPayloadSize=1232&dnssecValidation=true&eDnsClientSubnet=false&eDnsClientSubnetIPv4PrefixLength=24&eDnsClientSubnetIPv6PrefixLength=56&qpmLimitRequests=0&qpmLimitErrors=0&qpmLimitSampleMinutes=5&qpmLimitIPv4PrefixLength=24&qpmLimitIPv6PrefixLength=56&clientTimeout=4000&tcpSendTimeout=10000&tcpReceiveTimeout=10000&quicIdleTimeout=60000&quicMaxInboundStreams=100&listenBacklog=100&webServiceLocalAddresses=%5B%3A%3A%5D&webServiceHttpPort=8081&webServiceEnableTls=true&webServiceHttpToTlsRedirect=true&webServiceUseSelfSignedTlsCertificate=false&webServiceTlsPort=8443&webServiceTlsCertificatePath=%2Fopt%2Ftechnitium%2Fdns%2Fcerts%2Fcert.pfx&webServiceTlsCertificatePassword=************&enableDnsOverUdpProxy=false&enableDnsOverTcpProxy=false&enableDnsOverHttp=false&enableDnsOverTls=false&enableDnsOverHttps=false&enableDnsOverQuic=false&dnsOverUdpProxyPort=538&dnsOverTcpProxyPort=538&dnsOverHttpPort=80&dnsOverTlsPort=853&dnsOverHttpsPort=443&dnsOverQuicPort=853&dnsTlsCertificatePath=&dnsTlsCertificatePassword=&tsigKeys=false&recursion=AllowOnlyForPrivateNetworks&recursionDeniedNetworks=false&recursionAllowedNetworks=false&randomizeName=true&qnameMinimization=true&nsRevalidation=true&resolverRetries=2&resolverTimeout=2000&resolverMaxStackCount=16&saveCache=true&serveStale=true&serveStaleTtl=259200&cacheMaximumEntries=10000&cacheMinimumRecordTtl=10&cacheMaximumRecordTtl=604800&cacheNegativeRecordTtl=300&cacheFailureRecordTtl=10&cachePrefetchEligibility=2&cachePrefetchTrigger=9&cachePrefetchSampleIntervalInMinutes=5&cachePrefetchSampleEligibilityHitsPerHour=30&enableBlocking=true&allowTxtBlockingReport=true&blockingType=NxDomain&customBlockingAddresses=false&blockListUrls=https%3A%2F%2Fraw.githubusercontent.com%2FStevenBlack%2Fhosts%2Fmaster%2Fhosts%2Chttps%3A%2F%2Fmirror1.malwaredomains.com%2Ffiles%2Fjustdomains%2Chttps%3A%2F%2Fs3.amazonaws.com%2Flists.disconnect.me%2Fsimple_tracking.txt%2Chttps%3A%2F%2Fs3.amazonaws.com%2Flists.disconnect.me%2Fsimple_ad.txt&blockListUpdateIntervalHours=24&proxyType=socks5&proxyAddress=192.168.10.2&proxyPort=9050&proxyUsername=username&proxyPassword=password&proxyBypass=127.0.0.0%2F8%2C169.254.0.0%2F16%2Cfe80%3A%3A%2F10%2C%3A%3A1%2Clocalhost&forwarders=1.1.1.1&forwarderProtocol=Udp&forwarderRetries=3&forwarderTimeout=2000&forwarderConcurrency=2&enableLogging=true&logQueries=true&useLocalTime=false&logFolder=logs&maxLogFileDays=0&maxStatFileDays=0"
    
    echo "\n"
    echo "Nieuw wachtwoord voor admin account: $random_password"
fi
