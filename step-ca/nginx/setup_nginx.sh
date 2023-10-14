#!/bin/bash
echo start
while true; do
  if [ -z "$(ls /usr/share/nginx/data/)" ]; then
    echo "Wachten op bestanden..."
    sleep 1
  else
    cp /usr/share/nginx/data/* /media/.
    chown -R www-data:www-data /media/
    chmod 755 /media/*
    nginx
    break
  fi
done

sleep infinity
