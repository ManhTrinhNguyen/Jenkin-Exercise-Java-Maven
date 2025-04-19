#!/bin/bash
export IMAGE=$1
export USER=$2
export PASSWORD=$3

sudo yum update -y && yum install docker -y
sudo systemctl start docker
sudo usermod -aG docker ec2-user


# Dowload docker compose
curl -SL "https://github.com/docker/compose/releases/download/v2.35.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

# Login to Docker 

echo $PASSWORD | docker login -u $USER --password-stdin

docker-compose -f docker-compose.yaml up --detach

echo "success"