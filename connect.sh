#!/bin/bash

script -c "echo no | openconnect 199.7.162.42" /usr/share/orka/log.log 
grep 'pin-sha256:' /usr/share/orka/log.log | sed 's/.*://' > /usr/share/orka/servercert_nl.txt
awk '{print substr($0, 1, length($0)-1)}' /usr/share/orka/servercert_nl.txt > /usr/share/orka/servercert.txt

echo "$FIREWALL_PASS" | openconnect "$FIREWALL_IP" --user="$FIREWALL_USER" --servercert "pin-sha256:$(cat /usr/share/orka/servercert.txt)" --passwd-on-stdin --base-mtu=1450 --background
sleep 5
curl http://api.ipify.org