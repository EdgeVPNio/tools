#!/bin/bash

systemctl mask getty@tty1.service && \
mkdir -p /opt/evio && \
cd /opt/evio && \
python3.8 -m venv venv  && \
source venv/bin/activate && \
pip3 --cache-dir /var/cache/evio/ install wheel psutil slixmpp requests simplejson ryu pyroute2 && \
deactivate
