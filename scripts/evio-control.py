#!/usr/bin/env python3

import requests
import os
import subprocess
import logging
import logging.handlers as lh
import time
try:
    import simplejson as json
except ImportError:
    import json
    
config_file="/etc/opt/evio/config.json"
nid_file="/var/opt/evio/nid"
log_file="/var/log/evio/evio-control.log"
server_addr="x.x.x.x:5802"
logger=None

def runcmd(cmd):
    """ Run a shell command. if fails, raise an exception. """
    if cmd[0] is None:
        raise ValueError("No executable specified to run")
    p = subprocess.run(cmd, stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, check=False)
    return p

def setup_logger():
    global logger
    if os.path.isfile(log_file):
        os.remove(log_file)
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    handler = lh.RotatingFileHandler(filename=log_file, maxBytes=10000,backupCount=2)
    formatter = logging.Formatter(
        "[%(asctime)s.%(msecs)03d] %(levelname)s:%(message)s", datefmt="%Y%m%d %H:%M:%S")
    logging.Formatter.converter = time.localtime
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    
def node_id():
    with open(config_file) as f:
        config = json.load(f)
    if "NodeId" in config["CFx"]:
        return config["CFx"]["NodeId"]
    with open(nid_file) as f:
        return f.readline().strip('\n')
    
    
def main():
    setup_logger()
    nid = node_id()
    url=f'http://{server_addr}/eviocontrol/?nodeid={nid}'
    resp=requests.get(url).json()
    logger.info(f"Server response: {resp}")
    if resp and nid == resp[0]["EvioControl"]["NodeId"]:
        ctrl = resp[0]["EvioControl"]["Control"]
        if ctrl not in ("stop", "start", "status"):
            logger.info(f"Invalid evio control {ctrl} received from {url}")
            return
        cp = runcmd(["systemctl", ctrl, "openvswitch-switch"])
        logger.info(cp)
        cp = runcmd(["systemctl", ctrl, "evio"])
        logger.info(cp)
    logger.info("***************************************")

if __name__ == "__main__":
    main()