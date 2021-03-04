#!/bin/bash
cp -r /etc/evio/config/.env .
./startVisualizer.sh start
while :; do
  sleep 300
done