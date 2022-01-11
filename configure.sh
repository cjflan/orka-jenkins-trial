#!/bin/bash

./usr/share/orka/connect.sh
python3 /usr/share/orka/configure_cluster.py
echo "$FIREWALL_PASS" | openconnect "$FIREWALL_IP" --user="$FIREWALL_USER" --servercert "pin-sha256:$(cat /usr/share/orka/servercert.txt)" --passwd-on-stdin --base-mtu=1450