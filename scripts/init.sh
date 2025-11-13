#!/bin/bash 

docker network inspect "armory-network" > /dev/null
if [ $? -ne 0 ]; then
    docker network create -d bridge armory-network
else 
    echo "network already created"
fi

sh create-db.sh && \

sh create-armory.sh && \

sh create-nginx.sh 