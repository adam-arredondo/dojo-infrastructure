#!/bin/bash

# Install Docker
sudo yum update
curl -fsSL https://get.docker.com/ | sh
sudo service docker start
sudo docker run hello-world
if [ $? -eq 0 ]
  then
    echo "Docker successfully installed!"
  else
    echo "Docker install failed, exiting...."
    exit
  fi
# Setup Docker group
sudo groupadd docker
sudo usermod -aG docker ec2-user
sudo chkconfig docker on

# Install docker-compose
pip install docker-compose
