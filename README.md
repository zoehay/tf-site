# Terraform Personal Site

Terraform deployment of personal website and version control of required scripts, services, and Dockerfiles.

## Deployment on new instance

- Terraform instance and copy over init-instance.sh `scp files/init-instance.sh ec2-user@host:~/init-instance.sh`
- Run init-instance.sh to install docker, add ec2-user to docker group, and make app directory `chmod u+x init-instance.sh` `sudo bash init-instance.sh`
- Reconnect SSH to pick up group change
- Copy compose files, service files, and scripts
- `rsync -av --exclude='.DS_Store' files/ ec2-user@host:/opt/app/site`
- Copy images in, SSH in and load images
- `scp ${image-name}.tar ec2-user@host:/opt/app/site/${image-name}.tar`
- `docker load -i ${image-name}.tar`
- Check that HTTPS blocks in nginx are commented out
- Manually write secret files
  - `touch /opt/app/site/compose/e-commerce/secrets/db_password.txt`
  - `touch /opt/app/site/compose/gw2-armory/secrets/db_password.txt`
- Run init.sh to install certbot, setup docker network, install and start systemd services
- `sudo bash /opt/app/site/init.sh`
- un-comment HTTPS blocks in nginx files and `systemctl reload proxy.service`

## Deploying updates

- optional rename old image to keep for rollback `mv /opt/app/site/${image-name}.tar /opt/app/site/${image-name}.tar.bak"`

- rebuild and save image, scp into instance
- `scp ${image-name}.tar ec2-user@host:/opt/app/site/${image-name}.tar`
- SSH in and pick up new image
- `docker load -i ${image-name}.tar`
- `sudo systemctl restart proxy.service`

- cleanup old images `docker image prune -f`
