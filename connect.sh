#!/bin/bash

echo "$FIREWALL_PASS" | openconnect "$FIREWALL_IP" --user="$FIREWALL_USER" --servercert "$SERVER_CERT" --passwd-on-stdin --background
sleep 5
curl http://api.ipify.org