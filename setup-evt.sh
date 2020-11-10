#!/bin/bash
sudo apt install -y python3.8 python3.8-dev python3.8-venv python3-pip
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 40
deactivate 2>/dev/null
python -m venv venv && \
source venv/bin/activate && \
chmod 775 ./evt && \
pip3 install gitpython simplejson
