#!/bin/bash

export NODE_IDX=097

sudo apt-get update && sudo apt-get upgrade -y
# Install prereqs and openvswitch kernel module on raspberry-pi.
# linux-modules-extra-raspi is currently needed for rpi4/ubuntu server 22.04
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    linux-modules-extra-raspi

# auto load openvswitch kernel module at boot
echo openvswitch | sudo tee -a /etc/modules > /dev/null

# disable openvsiwtch on host if it is installed
sudo systemctl disable openvswitch-switch

# this file causes a conflict so remove if exists
sudo rm /etc/apt/sources.list.d/download_docker_com_linux_ubuntu.list

# Install docker
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get remove containerd.io docker-ce-cli docker-ce-rootless-extras docker-ce
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo chmod a+r /etc/apt/keyrings/docker.gpg && sudo apt-get update && \
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the user to docker group
me=$USER && sudo usermod -aG docker $me

sudo reboot
# pull latest edgevpn image
docker pull edgevpnio/evio-node:latest

mkdir /home/$USER/.evio
cp /etc/opt/evio/config.json /home/$USER/.evio/config-$NODE_IDX.json
docker run -d -v /home/$USER/.evio/config-097.json:/etc/opt/evio/config.json -v /var/log/evio/:/var/log/evio/ --restart always --privileged --name evio-node --network host edgevpnio/evio-node:latest