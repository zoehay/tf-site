# Terraform Personal Site

Terraform deployment of personal website and version control of required scripts, services, and Dockerfiles.

Local commands below are run from `scripts/` unless noted.

## Deployment on new instance

- Terraform instance, from `instances/`: `terraform apply -var-file=secret.tfvars`
- Get the Elastic IP `terraform output elastic_ip` and point DNS A records
- Copy over init-instance.sh `scp files/init-instance.sh ec2-user@host:~/init-instance.sh`
- Run init-instance.sh to install docker, add ec2-user to docker group, and make app directory `sudo bash init-instance.sh`
- Reconnect SSH to pick up group change
- Copy compose files, service files, and scripts
- `rsync -av --exclude='.DS_Store' files/ ec2-user@host:/opt/app/site`
- `scp ${image-name}.tar ec2-user@host:/opt/app/site/${image-name}.tar`
- `docker load -i /opt/app/site/${image-name}.tar`
- Check that HTTPS blocks in nginx are commented out
- Manually write secret files (must be non-empty or postgres will fail to initialize)
  - `mkdir -p /opt/app/site/compose/{e-commerce,gw2-armory}/secrets`
  - `openssl rand -hex 24 > /opt/app/site/compose/e-commerce/secrets/db_password.txt`
  - `openssl rand -hex 24 > /opt/app/site/compose/gw2-armory/secrets/db_password.txt`
  - `chmod 600 /opt/app/site/compose/{e-commerce,gw2-armory}/secrets/db_password.txt`
  - armory-backend runs as distroless `nonroot` (uid 65532), so it must own its file: `sudo chown 65532:65532 /opt/app/site/compose/gw2-armory/secrets/db_password.txt`
- Run init.sh to install certbot, setup docker network, install and start systemd services
- `sudo bash /opt/app/site/init.sh`
- un-comment HTTPS blocks in nginx files and `sudo systemctl reload proxy.service`

## Deploying updates

- SSH in and keep the current tar for rollback (overwrites any older `.bak`)
  - `mv /opt/app/site/${image-name}.tar /opt/app/site/${image-name}.tar.bak`
- Copy the new tar in
  - `scp ${image-name}.tar ec2-user@host:/opt/app/site/${image-name}.tar`
- SSH in and load the new image
  - `docker load -i /opt/app/site/${image-name}.tar`
- pick up the new image in the service that uses it
  - proxy-nginx: `sudo systemctl restart proxy.service`
  - e-commerce: `sudo systemctl reload e-commerce.service`
  - armory-backend: `sudo systemctl reload gw2-armory.service`
  - backend `reload` runs `compose up -d`, recreating only the backend container and leaving the db running; use `restart` only to recreate the whole stack (e.g. after changing the .service file)
- after reloading a backend service, also `sudo systemctl reload proxy.service`
  - nginx resolves backend container IPs only at startup/reload, so a recreated backend container returns 502 until nginx reloads
- Once the update is verified, cleanup old images `docker image prune -f`

## Rolling back

- `docker load -i /opt/app/site/${image-name}.tar.bak`
- Run the same service commands as in Deploying updates (including the proxy reload after a backend)
- Remove `.bak` tars that are no longer needed, they are not cleaned up automatically
  - `ls -lh /opt/app/site/*.tar.bak`

## Deploying nginx config changes

- `conf.d/*.conf` (directory mount): copy the changed file in, then `sudo systemctl reload proxy.service`
- `nginx.conf` (single-file mount): copy it in, then `sudo systemctl restart proxy.service`
  - a reload is not enough: scp/rsync replace the file rather than editing it in place, and a single-file bind mount keeps pointing at the old file until the container is recreated
