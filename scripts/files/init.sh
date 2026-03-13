#!/bin/bash 

set -exo pipefail

echo "Check for proxy-network"
docker network inspect "proxy-network" > /dev/null
if [ $? -ne 0 ]; then
    docker network create -d bridge proxy-network
    echo "Create proxy-network"
else 
    echo "Network already created"
fi

echo "Copy service files"
cp -r services/ /etc/systemd/system

echo "Reload systemctl"
sudo systemctl daemon-reload

# /etc/{app}/secrets

