while true; do
    if docker ps --filter "name=dns.pki.project" --filter "status=running" | grep -q "dns.pki.project"; then

        docker exec dns.pki.project /bin/bash -c "sh /media/setup_dns.sh"

        IP_DNS=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dns.pki.project)
        docker exec --user root -e IP_DNS="$IP_DNS" ca.pki.project bash -c 'echo -e "options rotate\noptions timeout:1\nnameserver 127.0.0.11\nnameserver $IP_DNS" | tee /etc/resolv.conf'

        break
    else
        echo "Wachten tot Container A is gestart..."
        sleep 5  # Wacht 5 seconden voordat je opnieuw controleert
    fi
done