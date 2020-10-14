#!/bin/bash
sudo apt install -y python3.8 python3.8-dev python3.8-venv python3-pip
# ls /usr/bin/python*
# update-alternatives --display python
# sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 10
# sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 20
# sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 30
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 40
# update-alternatives --display python
# python -V
deactivate 2>/dev/null
python -m venv venv && \
source venv/bin/activate && \
export PATH="$PATH:." && \
chmod 775 ./evt && \
pip3 install gitpython simplejson
