#!/bin/bash
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.9 python3.9-dev python3.9-venv python3-pip git
#sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 38
deactivate 2>/dev/null
python3.9 -m venv venv && \
source venv/bin/activate && \
chmod 775 ./evt && \
pip3 install gitpython simplejson
