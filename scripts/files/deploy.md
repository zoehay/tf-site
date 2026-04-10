# Deployment

- Terraform instance, `scp files/init-instance.sh ec2-user@host:~/init-instance.sh`
- SSH in `sudo bash init-instance.sh` to install docker and add ec2-user to docker group
- Reconnect SSH to pick up group change
- Copy compose files, service files, and scripts `scp -r files/ ec2-user@host:/opt/app/site`
- `docker login` as ec2-user and `docker pull` images
- Check that HTTPS blocks in nginx are commented out
- Manually write secret files
  - `touch /opt/app/site/compose/e-commerce/secrets/db_password.txt`
  - `touch /opt/app/site/compose/gw2-armory/secrets/db_password.txt`
- `sudo bash /opt/app/site/init.sh` to install certbot, setup docker network, install and start systemd services
- un-comment HTTPS blocks in nginx files and `systemctl reload proxy.service`

## Frontend updates

- rebuild and push nginx proxy image with updated www files
- ssh in `docker pull` new nginx image
- `sudo systemctl restart proxy.service`
