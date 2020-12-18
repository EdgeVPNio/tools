#!/bin/bash

systemctl mask getty@tty1.service && \
mkdir -p /opt/evio && \
cd /opt/evio && \
python3.8 -m venv venv  && \
source venv/bin/activate && \
pip3 --no-cache-dir install wheel psutil slixmpp requests simplejson ryu && \
deactivate
