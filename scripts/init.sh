#!/bin/bash 

docker network inspect "site-network" > /dev/null
if [ $? -ne 0 ]; then
    docker network create -d bridge site-network
else 
    echo "network already created"
fi
