#!/bin/bash

# Load environment variables from the .env file
set -o allexport
source .env
set +o allexport

docker compose up -d
while true; do
    # Check if the DNS container is running with the specified name and in a running state
    if docker ps --filter "name=dns.$PKI_DOMAIN_NAME" --filter "status=running" | grep -q "dns.$PKI_DOMAIN_NAME"; then

        # Execute a command inside the DNS container to run the 'setup_dns.sh' script
        docker exec dns.$PKI_DOMAIN_NAME /bin/bash -c "sh /media/setup_dns.sh"

        # Obtain the IP address of the DNS container
        IP_DNS=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dns.$PKI_DOMAIN_NAME)

        # Update the '/etc/resolv.conf' file inside the CA container to use the DNS container's IP address
        docker exec --user root -e IP_DNS="$IP_DNS" ca.$PKI_DOMAIN_NAME bash -c 'echo -e "options rotate\noptions timeout:1\nnameserver 127.0.0.11\nnameserver $IP_DNS" > /etc/resolv.conf'

        break
    else
        echo "Waiting for Container A to start..." # Display a message while waiting
        sleep 5
    fi
done
