#!/bin/bash

# nginx with mounted conf file for dev
docker container create \
    --name nginx \
    --restart unless-stopped \
    --network site-network \
    -v $(pwd)/nginx/local-certs/certs:/etc/nginx/certs:ro \
    -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
    -p 80:80 \
    -p 443:443 \
    nginx:tf-site

# docker container create \
#     --name nginx \
#     --restart unless-stopped \
#     --network site-network \
#     -v /etc/letsencrypt/:/etc/letsencrypt/ \
#     -p 80:80 \
#     -p 443:443 \
#     nginx:tf-site


#### e-commerce 
docker container create \
    --name db \
    --restart unless-stopped \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_DB=prisma_e_commerce \
    -e POSTGRES_PASSWORD_FILE=/run/secrets/db_password.txt \
    --network site-network \
    -v ecomm:/var/lib/postgresql/data \
    -v $(pwd)/secrets/ecom_db_password.txt:/run/secrets/db_password.txt:ro \
    postgres:16

docker container create \
    --name backend \
    --restart unless-stopped \
    -e POSTGRES_PASSWORD_FILE=/run/secrets/db_password.txt \
    -e DB_USER=postgres \
    -e DB_HOST=db \
    -e DB_PORT=5432 \
    -e DB_NAME=prisma_e_commerce \
    -e DB_SCHEMA=public \
    -e CORS_ALLOW_ORIGIN='http://e-commerce.localhost https://e-commerce.localhost http://angular-e-commerce.localhost https://angular-e-commerce.localhost' \
    --network site-network \
    -v $(pwd)/secrets/ecom_db_password.txt:/run/secrets/db_password.txt:ro \
    backend:e-commerce


#### gw2-armory
docker container create \
    --name armory-db \
    --network site-network \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_DB=armory \
    -e POSTGRES_PASSWORD_FILE=/run/secrets/db_password.txt \
    -v tfarmorydb:/var/lib/postgresql/data \
    -v $(pwd)/secrets/armory_db_password.txt:/run/secrets/db_password.txt:ro \
    postgres:16

docker container create \
    --name armory-backend \
    --restart unless-stopped \
    -e ARMORY_DB_PASSWORD_FILE=/run/secrets/db_password.txt \
    -e CORS_ALLOW_ORIGIN='https://armory.localhost http://armory.localhost' \
    -e DOMAIN='armory.localhost' \
    --network site-network \
    -v $(pwd)/secrets/armory_db_password.txt:/run/secrets/db_password.txt:ro \
    armory-backend