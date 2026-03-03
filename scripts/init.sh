#!/bin/bash 

# check for and create proxy network
docker network inspect "proxy-network" > /dev/null
if [ $? -ne 0 ]; then
    docker network create -d bridge proxy-network
else 
    echo "network already created"
fi

# /etc/{app}/secrets

