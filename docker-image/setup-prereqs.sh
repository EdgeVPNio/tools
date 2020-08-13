#!/bin/bash

systemctl mask getty@tty1.service && \
mkdir -p /opt/edge-vpnio && \
cd /opt/edge-vpnio && \
python3 -m venv venv  && \
source venv/bin/activate && \
pip3 --no-cache-dir install wheel psutil slixmpp requests simplejson ryu && \
deactivate
