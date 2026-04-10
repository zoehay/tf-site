#!/bin/bash
set -euo pipefail

# Install Docker from AL2023 repos
dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker without sudo
usermod -aG docker ec2-user

# Install Docker Compose v2 plugin
ARCH=$(uname -m)
COMPOSE_VERSION=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d'"' -f4)
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${ARCH}" \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Create app directory owned by ec2-user
mkdir -p /opt/app/site
chown ec2-user:ec2-user /opt/app/site