#!/bin/bash
set -euo pipefail

# Application Init
# For a fresh instance 
# - Copy compose files, service files, and scripts to /opt/app/site
#   - cp -r files/ /opt/app/site
# - Check that HTTPS block in nginx is commented out
# - Manually write secret files 
#   - touch /opt/app/site/compose/e-commerce/secrets/ecom_db_password.txt
#   - touch /opt/app/site/compose/gw2-armory/secrets/armory_db_password.txt
#   - Sign into docker 

APP_DIR="/opt/app/site"
SYSTEMD_DIR="/etc/systemd/system"
CERTBOT_WEBROOT="/var/www/certbot"
NGINX_HOOK="/etc/letsencrypt/renewal-hooks/post/reload-nginx.sh"
CERTBOT_EMAIL=""

ARMORY_IMAGE="armory-backend"
E_COMMERCE_IMAGE="backend:e-commerce"
NGINX_PROXY_IMAGE="nginx:tf-site"

bail() { echo "[ERROR] $*" >&2; exit 1; }
cert_exists() { [[ -f "/etc/letsencrypt/live/$1/fullchain.pem" ]]; }

# Preflight checks 

echo "Running preflight checks..."

[[ $EUID -eq 0 ]] || bail "Script must be run as root."

[[ -d "$APP_DIR" ]] || bail "$APP_DIR does not exist. Copy app files first."

for f in proxy.service app1.service app2.service certbot-renew.service certbot-renew.timer; do
    [[ -f "$APP_DIR/services/$f" ]] || bail "Missing service file: $APP_DIR/$f"
done

docker info &>/dev/null || bail "Docker is not running or this user cannot reach the socket."

### Install Certbot 

echo "Installing certbot..."
if ! command -v certbot &>/dev/null; then
    apt-get update -qq
    apt-get install -y -qq certbot
    echo "Certbot installed: $(certbot --version 2>&1)"
else
    echo "Certbot already installed: $(certbot --version 2>&1)"
fi

# `sudo ln -s /snap/bin/certbot /usr/bin/certbot`

### Pull app images 

echo "Pulling Docker images..."
docker pull "$ARMORY_IMAGE"\
    || bail "docker pull $ARMORY_IMAGE failed"
docker pull "$E_COMMERCE_IMAGE"\
    || bail "docker pull $E_COMMERCE_IMAGE failed"
docker pull "$NGINX_PROXY_IMAGE"\
    || bail "docker pull $NGINX_PROXY_IMAGE failed"

### Setup proxy-network

echo "Checking for proxy-network..."
if ! docker network inspect proxy-network &>/dev/null; then
    docker network create proxy-network
    echo "Created proxy-network"
else
    echo "Docker proxy-network already exists."
fi

### Create certbot webroot directory 

echo "Creating certbot webroot at $CERTBOT_WEBROOT..."
mkdir -p "$CERTBOT_WEBROOT"
chown -R root:root "$CERTBOT_WEBROOT"

### Install systemd services 

echo "Copying systemd unit files to $SYSTEMD_DIR..."
for f in proxy.service gw2-armory.service e-commerce.service certbot-renew.service certbot-renew.timer; do
    cp "$APP_DIR/services/$f" "$SYSTEMD_DIR/$f"
    echo "installed $f"
done
systemctl daemon-reload

### Start app services 

echo "Enabling and starting app services..."
systemctl enable --now gw2-armory.service
systemctl enable --now e-commerce.service

echo "Verifying app services are active..."
systemctl is-active gw2-armory.service || bail "gw2-armory.service failed to start."
systemctl is-active e-commerce.service || bail "e-commerce.service failed to start."

### Start proxy with HTTP-only config 

echo "Starting nginx proxy service (HTTP-only block)..."
systemctl enable --now proxy.service
systemctl is-active proxy.service || bail "proxy.service failed to start."

### add nginx reload to certbot post-renew hook

echo "Installing certbot post-renewal nginx reload hook..."
mkdir -p "$(dirname "$NGINX_HOOK")"
cat > "$NGINX_HOOK" <<'EOF'
#!/bin/bash
# Reload nginx after cert renewal
sudo systemctl reload proxy.service
EOF
chmod +x "$NGINX_HOOK"
echo "Hook installed at $NGINX_HOOK"

### certbot certificates

for domain in gw2-armory.com zoemhay.com e-commerce.zoemhay.com angular-e-commerce.zoemhay.com; do
    if cert_exists "$domain"; then
        log "Cert already exists for $domain -- skipping certbot."
    else
        log "Running certbot for $domain..."
        certbot certonly \
            --webroot \
            --webroot-path "$CERTBOT_WEBROOT" \
            --non-interactive \
            --agree-tos \
            --email "$CERTBOT_EMAIL" \
            -d "$domain" \
            || bail "certbot failed for $domain"
        log "Cert issued for $domain."
    fi
done

### enable certbot renew

echo "Enabling certbot-renew.timer"

systemctl enable --now certbot-renew.timer
systemctl is-active certbot-renew.timer || bail "certbot-renew.timer failed to start."

echo "Certbot renewal timer active:"
systemctl status certbot-renew.timer --no-pager

echo " Init complete."
echo " Cert renewal timer: $(systemctl show certbot-renew.timer -p NextElapseUSecRealtime --value)"

echo "ACTION REQUIRED: Reload proxy with the HTTPS nginx config now."
echo "Then reload proxy.service with: systemctl reload proxy.service"
