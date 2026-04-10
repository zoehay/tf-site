#!/bin/bash
set -euo pipefail

# Install Docker
dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker without sudo
usermod -aG docker ec2-user

# Install Docker Compose v2 plugin (enables `docker compose` subcommand)
dnf install -y docker-compose-plugin

# Create app directory owned by ec2-user
mkdir -p /opt/app/site
chown ec2-user:ec2-user /opt/app/site