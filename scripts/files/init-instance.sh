#!/bin/bash
set -euo pipefail

# Install Docker
dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker without sudo
usermod -aG docker ec2-user

# Install Docker Compose v2
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)  
curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-aarch64" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Create app directory owned by ec2-user
mkdir -p /opt/app/site
chown ec2-user:ec2-user /opt/app/site