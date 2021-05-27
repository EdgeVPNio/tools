#!/bin/bash
cp -r /etc/evio/config/.env .
./visualizer start
while :; do
  sleep 300
done
