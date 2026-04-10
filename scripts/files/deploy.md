# Deployment

- Terraform instance, ssh in, and copy compose files, service files, and scripts `scp -r files/ /opt/app/site`
- `sudo bash init-instance.sh` to install docker and add ec2-user to docker group
- Reconnect SSH to pick up group change
- `docker login` as ec2-user and `docker pull` images
- Check that HTTPS blocks in nginx are commented out
- Manually write secret files
  - touch /opt/app/site/compose/e-commerce/secrets/ecom_db_password.txt
  - touch /opt/app/site/compose/gw2-armory/secrets/armory_db_password.txt
- `sudo bash init.sh` to install certbot, setup docker network, install and start systemd services
- un-comment HTTPS blocks in nginx files and `systemctl reload proxy.service`

## Frontend updates

- rebuild and push nginx proxy image with updated www files
- ssh in `docker pull` new nginx image
- `sudo systemctl restart proxy.service`
