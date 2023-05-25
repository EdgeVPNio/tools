#!/usr/bin/env python3
try:
    import simplejson as json
except ImportError:
    import json

import argparse
import ipaddress
import os
import pathlib
import pickle
import random
import shutil
import subprocess
import sys
import time
from copy import deepcopy

from template import BASE_TEMAPLTE, NODE_ID, UPDATES


class ConfigGen:
    def __init__(
        self,
    ):
        parser = argparse.ArgumentParser(
            description="Generates EdgeVPN config files for a range of nodes",
            fromfile_prefix_chars="@",
        )
        parser.add_argument(
            "-t",
            "--template",
            action="store",
            dest="template",
            type=str,
            help="Fully qualified filename for configuration template used to generate the others",
        )
        parser.add_argument(
            "-u",
            "--updates",
            action="store",
            dest="updates",
            help="Fully qualified filename for configuration parameters to merge/overwrite on the template ",
        )
        parser.add_argument(
            "-o",
            "--output_dir",
            action="store",
            dest="output_dir",
            type=pathlib.Path,
            help="Directory for generated configuration files",
        )

        parser.add_argument(
            "-r",
            "--range",
            action="store",
            dest="range",
            nargs=2,
            required=True,
            help="Specifies the range of files to genereate",
        )
        self.args = parser.parse_args()
        self.range_end = int(self.args.range[1])
        self.range_start = int(self.args.range[0])
        if not self.args.output_dir:
            self.output_dir = os.path.abspath(".")
        else:
            self.args.output_dir.mkdir(exist_ok=True)
            self.output_dir = str(self.args.output_dir)
        self.config_file_base = "{0}/config-".format(self.output_dir)

    def gen(self):
        config = deepcopy(UPDATES)
        node_id = NODE_ID
        for val in range(self.range_start, self.range_end):
            rng_str = "{0:03}".format(val)
            cfg_file = f"{self.config_file_base}{rng_str}.json"
            node_id = "{0}{1}{2}{1}{3}".format(
                node_id[:4], rng_str, node_id[7:29], node_id[32:]
            )
            overlays = config["Broker"].get("Overlays", [])
            config["Broker"]["NodeId"] = node_id
            for olid in overlays:
                netwk = config["BridgeController"]["Overlays"][olid]["NetDevice"][
                    "AppBridge"
                ].pop("NetworkAddress")
                netwk = ipaddress.IPv4Network(netwk)
                node_ip = str(netwk[val])
                config["BridgeController"]["Overlays"][olid]["NetDevice"]["AppBridge"][
                    "IP4"
                ] = node_ip
                config["BridgeController"]["Overlays"][olid]["NetDevice"]["AppBridge"][
                    "PrefixLen"
                ] = netwk.prefixlen
                config["Topology"]["Overlays"][olid]["LocationId"] = val
            with open(cfg_file, "w") as cfg_fle:
                json.dump(config, cfg_fle, indent=2)
                cfg_fle.flush()
            config = deepcopy(UPDATES)

        print("{0} config file(s) generated".format(self.range_end - self.range_start))


def main():  # pylint: disable=too-many-return-statements
    cfg = ConfigGen()
    cfg.gen()


if __name__ == "__main__":
    main()
