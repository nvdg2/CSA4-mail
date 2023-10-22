#!/bin/bash


# Check if 'wget' and 'curl' are available; if not, install them.
if [ ! -e "/opt/technitium/dns/certs/cert.pfx" ];
then
    apt update
    apt install curl -y

    # Download and install step-cli
    curl -L https://dl.smallstep.com/gh-release/cli/gh-release-header/v0.25.0/step-cli_0.25.0_amd64.deb > step-cli.deb
    dpkg -i step-cli.deb

    # Create a 'certs' directory and navigate to it
    cd certs

    # Download the root CA certificate
    curl -k "https://ca.$PKI_DOMAIN_NAME:9000/roots.pem" > root_ca.crt

    # Generate certificates using 'step'
    step ca certificate dns.$PKI_DOMAIN_NAME key.pem cert.pem -provisioner acme --ca-url https://ca.$PKI_DOMAIN_NAME:9000 --root ./root_ca.crt
    openssl pkcs12 -export -out cert.pfx -inkey cert.pem -in key.pem -passout pass:

    # Generate a random 25-character password
    random_password=$(openssl rand -base64 25)

    # Request token for other API calls
    json=$(curl "http://localhost:8081/api/user/login?user=admin&pass=admin&includeInfo=true")
    token_value=$(echo $json | grep -o '"token":"[^"]*"' | awk -F '"' '{print $4}')
    
    # Change the password for the 'admin' account
    curl "http://localhost:8081/api/user/changePassword?token=$token_value&pass=$random_password"

    # Configure various settings using 'curl'
    curl "http://localhost:8081/api/settings/set?token=$token_value&dnsServerDomain=$PKI_DOMAIN_NAME&dnsServerLocalEndPoints=0.0.0.0%3A53%2C%5B%3A%3A%5D%3A53&defaultRecordTtl=3600&dnsAppsEnableAutomaticUpdate=true&preferIPv6=false&udpPayloadSize=1232&dnssecValidation=true&eDnsClientSubnet=false&eDnsClientSubnetIPv4PrefixLength=24&eDnsClientSubnetIPv6PrefixLength=56&qpmLimitRequests=0&qpmLimitErrors=0&qpmLimitSampleMinutes=5&qpmLimitIPv4PrefixLength=24&qpmLimitIPv6PrefixLength=56&clientTimeout=4000&tcpSendTimeout=10000&tcpReceiveTimeout=10000&quicIdleTimeout=60000&quicMaxInboundStreams=100&listenBacklog=100&webServiceLocalAddresses=%5B%3A%3A%5D&webServiceHttpPort=8081&webServiceEnableTls=true&webServiceHttpToTlsRedirect=true&webServiceUseSelfSignedTlsCertificate=true&webServiceTlsPort=8443&webServiceTlsCertificatePath=%2Fopt%2Ftechnitium%2Fdns%2Fcerts%2Fcert.pfx&webServiceTlsCertificatePassword=&enableDnsOverUdpProxy=false&enableDnsOverTcpProxy=false&enableDnsOverHttp=false&enableDnsOverTls=false&enableDnsOverHttps=false&enableDnsOverQuic=false&dnsOverUdpProxyPort=538&dnsOverTcpProxyPort=538&dnsOverHttpPort=80&dnsOverTlsPort=853&dnsOverHttpsPort=443&dnsOverQuicPort=853&dnsTlsCertificatePath=&dnsTlsCertificatePassword=&tsigKeys=false&recursion=AllowOnlyForPrivateNetworks&recursionDeniedNetworks=false&recursionAllowedNetworks=false&randomizeName=true&qnameMinimization=true&nsRevalidation=true&resolverRetries=2&resolverTimeout=2000&resolverMaxStackCount=16&saveCache=true&serveStale=true&serveStaleTtl=259200&cacheMaximumEntries=10000&cacheMinimumRecordTtl=10&cacheMaximumRecordTtl=604800&cacheNegativeRecordTtl=300&cacheFailureRecordTtl=10&cachePrefetchEligibility=2&cachePrefetchTrigger=9&cachePrefetchSampleIntervalInMinutes=5&cachePrefetchSampleEligibilityHitsPerHour=30&enableBlocking=true&allowTxtBlockingReport=true&blockingType=NxDomain&customBlockingAddresses=false&blockListUrls=false&blockListUpdateIntervalHours=24&proxyType=none&forwarders=cloudflare-dns.com%20(1.1.1.1%3A853)%2Ccloudflare-dns.com%20(1.0.0.1%3A853)&forwarderProtocol=Tls&forwarderRetries=3&forwarderTimeout=2000&forwarderConcurrency=2&enableLogging=true&logQueries=false&useLocalTime=false&logFolder=logs&maxLogFileDays=0&maxStatFileDays=0"
    
    echo "\n"
    echo "New password for the admin account: $random_password"
fi
