#!/bin/bash
dir=$(pwd)
cd /data
mongod &
cd $dir
node server/Server.js