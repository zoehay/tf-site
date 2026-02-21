#!/bin/bash
 
mkcert -cert-file ./certs/localhost.crt -key-file ./certs/localhost.key localhost

openssl req -x509 -out ./certs/e-commerce.localhost.crt -keyout ./certs/e-commerce.localhost.key \
    -newkey rsa:2048 -nodes -sha256 \
    -subj '/CN=e-commerce.localhost' -extensions EXT -config <(printf "[dn]\nCN=e-commerce.localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:e-commerce.localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

openssl req -x509 -out ./certs/angular-e-commerce.localhost.crt -keyout ./certs/angular-e-commerce.localhost.key \
    -newkey rsa:2048 -nodes -sha256 \
    -subj '/CN=angular-e-commerce.localhost' -extensions EXT -config <(printf "[dn]\nCN=angular-e-commerce.localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:angular-e-commerce.localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
