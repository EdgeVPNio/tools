#!/usr/bin/env python3
# pylint: disable=missing-docstring
try:
    import simplejson as json
except ImportError:
    import json
import sys
import os
import subprocess
import random
from distutils import spawn
import pickle
import argparse
import shutil
import time
from abc import ABCMeta, abstractmethod
import ipaddress
PACKAGE_PARENT = '..'
SCRIPT_DIR = os.path.dirname(os.path.realpath(os.path.join(os.getcwd(), os.path.expanduser(__file__))))
sys.path.append(os.path.normpath(os.path.join(SCRIPT_DIR, PACKAGE_PARENT)))

from versioning.tool_config import MAJOR_VER
from versioning.tool_config import MINOR_VER
from versioning.tool_config import REVISION_VER
from versioning.tool_config import CONTROL_VER
from versioning.tool_config import OFFICIAL

class Testbed():
    __metaclass__ = ABCMeta

    LAUNCH_WAIT = 5
    BATCH_SZ = 5
    VIRT = NotImplemented
    APT = spawn.find_executable("apt-get")
    CONTAINER = NotImplemented
    BF_VIRT_IMG = "edgevpnio/evio-node:21.6.0.130-dev"

    def __init__(self, exp_dir=None):
        parser = argparse.ArgumentParser(
            description="Configures and runs EdgeVPN Testbed")
        parser.add_argument("--clean", action="store_true", default=False, dest="clean",
                            help="Removes all generated files and directories")
        parser.add_argument("--configure", action="store_true", default=False, dest="configure",
                            help="Generates the config files and directories")
        parser.add_argument("-v", action="store_true", default=False, dest="verbose",
                            help="Print testbed activity info")
        parser.add_argument("--range", action="store", dest="range",
                            help="Specifies the testbed start and end range in format #,#")
        parser.add_argument("--slice", action="store", dest="slice",
                            help="Specifies the portion of the range to use. Given in format slice=#,#")
        parser.add_argument("--run", action="store_true", default=False, dest="run",
                            help="Runs the currently configured testbed")
        parser.add_argument("--end", action="store_true", default=False, dest="end",
                            help="End the currently running testbed")
        parser.add_argument("--info", action="store_true", default=False, dest="info",
                            help="Displays the current testbed configuration")
        parser.add_argument("--setup", action="store_true", default=False, dest="setup",
                            help="Installs software requirements. Requires run as root.")
        parser.add_argument("--pull", action="store_true", default=False, dest="pull",
                            help="Pulls the {} image from docker hub"
                            .format(Testbed.BF_VIRT_IMG))
        parser.add_argument("--lxd", action="store_true", default=False, dest="lxd",
                            help="Uses LXC containers")
        parser.add_argument("--dkr", action="store_true", default=False, dest="dkr",
                            help="Use docker containers")
        parser.add_argument("--ping", action="store", dest="ping",
                            help="Ping the specified address from each container")
        parser.add_argument("--arp", action="store", dest="arp",
                            help="arPing the specified address from each container")
        parser.add_argument("--evio", action="store", dest="evio",
                            help="Perform the specified service action: stop/start/restart")
        parser.add_argument("--churn", action="store", dest="churn",
                            help="Restarts the specified amount of nodes in the overlay,"
                            "one every interval")
        parser.add_argument("--test", action="store", dest="test",
                            help="Performs latency and bandwidth test between random pairs of "
                            "nodes. Ex test=<test_name>")

        self.args = parser.parse_args()
        self.exp_dir = exp_dir
        if not self.exp_dir:
            self.exp_dir = os.path.abspath(".")
        self.bld_num_file = "/var/tmp/evio_build_number"
        self.load_build_ver_info()
        Testbed.BF_VIRT_IMG = "edgevpnio/evio-node:{0}.{1}.{2}".format(
            MAJOR_VER, MINOR_VER, REVISION_VER)
        if not OFFICIAL:
          Testbed.BF_VIRT_IMG += ".{0}-{1}".format(self._bld_num, "dev")
        self.template_file = "{0}/template-config.json".format(self.exp_dir)
        self.config_dir = "{0}/config".format(self.exp_dir)
        self.log_dir = "{0}/log".format(self.exp_dir)
        self.data_dir = "{0}/data".format(self.exp_dir)
        self.cert_dir = "{0}/cert".format(self.exp_dir)
        self.config_file_base = "{0}/config-".format(self.config_dir)
        self.seq_file = "{0}/startup.list".format(self.exp_dir)
        self.range_file = "{0}/range_file".format(self.exp_dir)

        if self.args.range:
            rng = self.args.range.strip().rsplit(",", 2)
            self.range_end = int(rng[1]) + 1
            self.range_start = int(rng[0])
        elif not self.args.range and os.path.isfile("range_file"):
            with open(self.range_file) as rng_fle:
                self.args.range = rng_fle.read()
                rng = self.args.range.strip().rsplit(",", 2)
                self.range_end = int(rng[1]) + 1
                self.range_start = int(rng[0])
        else:
            raise RuntimeError("Range unspecified")

        self.seq_list : list
        self.load_seq_list()

        self.slice_end = len(self.seq_list)
        self.slice_start = int(0)
        if self.args.slice:
            slc = self.args.slice.rsplit(",", 2)
            self.slice_end = int(slc[1])
            self.slice_start = int(slc[0])
            
        self.total_inst = self.slice_end - self.slice_start

    @classmethod
    def runshell(cls, cmd):
        """ Run a shell command. if fails, raise an exception. """
        if cmd[0] is None:
            raise ValueError("No executable specified to run")
        resp = subprocess.run(cmd, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)
        return resp

    @property
    @abstractmethod
    def gen_config(self, range_start, range_end):
        pass

    @property
    @abstractmethod
    def start_instance(self, instance):
        pass

    @property
    @abstractmethod
    def end(self):
        pass

    def load_build_ver_info(self):
        with open(self.bld_num_file, "r") as bn_fle:
            self._bld_num = int(bn_fle.read())

    def clean_config(self):
        if os.path.isdir(self.config_dir):
            shutil.rmtree(self.config_dir)
            if self.args.verbose:
                print("Removed dir {}".format(self.config_dir))
        if os.path.isfile(self.seq_file):
            os.remove(self.seq_file)
            if self.args.verbose:
                print("Removed file {}".format(self.seq_file))

    def make_clean(self):
        self.clean_config()
        if os.path.isdir(self.log_dir):
            shutil.rmtree(self.log_dir)
            if self.args.verbose:
                print("Removed dir {}".format(self.log_dir))

    def configure(self):
        with open(self.range_file, "w") as rng_fle:
            rng_fle.write(self.args.range)
        self.gen_config(self.range_start, self.range_end)
        self.save_seq_list()

    def save_seq_list(self):
        with open(self.seq_file, "wb") as seq_fle:
            pickle.dump(self.seq_list, seq_fle)
            seq_fle.flush()
        if self.args.verbose:
            print("Instance sequence saved with {0} entries\n{1}"
                  .format(self.total_inst, self.seq_list))

    def load_seq_list(self):
        if os.path.isfile(self.seq_file):
            with open(self.seq_file, "rb") as seq_fle:
                self.seq_list = pickle.load(seq_fle)
            if self.args.verbose:
                print("Sequence list loaded from existing file -  {0} entries\n{1}".
                      format(len(self.seq_list), self.seq_list))
        else:
            self.seq_list = list(range(self.range_start, self.range_end))
            random.shuffle(self.seq_list)

    def start_range(self, num, wait):
        cnt = 0
        #sequence = self.seq_list[self.range_start-1:self.range_end]
        sequence = self.seq_list[self.slice_start:self.slice_end]
        for inst in sequence:
            self.start_instance(inst)
            cnt += 1
            if cnt % num == 0 and cnt < len(sequence):
                # if self.args.verbose:
                print("{0}/{1} container(s) instantiated".format(cnt, len(sequence)))
                time.sleep(wait)
        print("{0} container(s) instantiated".format(cnt))

    def run(self):
        self.start_range(Testbed.BATCH_SZ, Testbed.LAUNCH_WAIT)

    def display_current_config(self):
        print("----Testbed Configuration----")
        print("Major:{0}, Minor:{1}, Revision:{2}, Build:{3}, Control:{4}, Official:{5}"
              .format(MAJOR_VER, MINOR_VER, REVISION_VER, self._bld_num, CONTROL_VER, OFFICIAL))
        print("{0} instances range {1}-{2}".format(self.total_inst, self.slice_start,
                                                   self.slice_end))
        print("Config dir {0}".format(self.config_dir))
        print("Config base filename {0}".format(self.config_file_base))
        print("Log dir {0}".format(self.log_dir))
        print("Contianer image {0}".format(Testbed.BF_VIRT_IMG))
        print("".format())

    def setup_system(self):
        setup_cmds = [["./setup-system.sh"]]
        for cmd_list in setup_cmds:
            if self.args.verbose:
                print(cmd_list)
            resp = Testbed.runshell(cmd_list)
            print(resp.stdout.decode("utf-8") if resp.returncode == 0 else
                  resp.stderr.decode("utf-8"))

    @abstractmethod
    def run_container_cmd(self, cmd_line, instance_num):
        pass

    def churn(self, param):
        params = param.rsplit(",", 2)
        iters = int(params[0])
        inval = int(params[1])
        self._churn(iters, inval)

    def _churn(self, churn_count=0, interval=30):
        if churn_count == 0:
            churn_count = self.total_inst
        cnt = 0
        restarted_nds = set()
        while cnt < churn_count:
            inst = random.choice(range(self.slice_start, self.slice_end))
            print("Stopping node", inst)
            self.run_container_cmd(["systemctl", "stop", "evio"], inst)
            if self.args.verbose:
                print("Waiting", interval, "seconds")
            time.sleep(interval)
            print("Resuming node", inst)
            self.run_container_cmd(["systemctl", "start", "evio"], inst)
            restarted_nds.add(inst)
            cnt += 1
            if self.args.verbose:
                print("Waiting", interval, "seconds")
            time.sleep(interval)
        if self.args.verbose:
            print("{0} nodes restarted\n{1}".format(cnt, str(restarted_nds)))

    def run_test(self):
        # test = None
        # if self.args.test == "lui":
        #     test = TestLinkUtilization()
        #     test.create_input_files()
        # if self.args.test == "lur":
        #     test = TestLinkUtilization()
        #     test.create_result_report()
        print("Test case not implemented")


class DockerTestbed(Testbed):
    VIRT = spawn.find_executable("docker")
    CONTAINER = "evio-dkr{0}"

    def __init__(self, exp_dir=None):
        super().__init__(exp_dir=exp_dir)
        self.network_name = "dkrnet"

    # def configure(self):
    #    super().configure()
    #    self.pull_image()

    def create_network(self):
        # netid=docker network ls | grep dkrnet | awk 'BEGIN { FS=" "} {print $2}'
        # docker network create dkrnet
        pass

    def gen_config(self, range_start, range_end):
        with open(self.template_file) as cfg_tmpl:
            template = json.load(cfg_tmpl)
        olid = template["CFx"].get("Overlays", None)
        olid = olid[0]
        node_id = template["CFx"].get(
            "NodeId", "a000###feb6040628e5fb7e70b04f###")
        node_name = template["OverlayVisualizer"].get("NodeName", "dkr###")
        netwk = template["BridgeController"]["Overlays"][olid]["NetDevice"]["AppBridge"].get(
            "NetworkAddress", "10.10.1.0/24")
        netwk = ipaddress.IPv4Network(netwk)
        for val in range(range_start, range_end):
            rng_str = "{0:03}".format(val)
            cfg_file = "{0}{1}.json".format(self.config_file_base, rng_str)
            node_id = "{0}{1}{2}{1}{3}".format(
                node_id[:4], rng_str, node_id[7:29], node_id[32:])
            node_name = "{0}{1}".format(node_name[:3], rng_str)
            node_ip = str(netwk[val])
            template["CFx"]["NodeId"] = node_id
            template["OverlayVisualizer"]["NodeName"] = node_name
            template["BridgeController"]["Overlays"][olid]["NetDevice"]["AppBridge"]["IP4"] = node_ip
            template["BridgeController"]["Overlays"][olid]["NetDevice"]["AppBridge"]["PrefixLen"] = netwk.prefixlen
            os.makedirs(self.config_dir, exist_ok=True)
            with open(cfg_file, "w") as cfg_fle:
                json.dump(template, cfg_fle, indent=2)
                cfg_fle.flush()
        if self.args.verbose:
            print("{0} config file(s) generated".format(range_end-range_start))

    def start_instance(self, instance):
        instance = "{0:03}".format(instance)
        container = DockerTestbed.CONTAINER.format(instance)
        log_dir = "{0}/dkr{1}".format(self.log_dir, instance)
        os.makedirs(log_dir, exist_ok=True)

        cfg_file = "{0}{1}.json".format(self.config_file_base, instance)
        if not os.path.isfile(cfg_file):
            self.gen_config(instance, instance+1)

        mount_cfg = "{0}:/etc/opt/evio/config.json".format(cfg_file)
        mount_log = "{0}/:/var/log/evio/".format(log_dir)
        #mount_data = "{0}/:/var/evio/".format(self.data_dir)
        mount_cert = "{0}/:/var/evio/cert/".format(self.cert_dir)
        args = ["--rm", "--privileged"]
        opts = "-d"
        img = Testbed.BF_VIRT_IMG
        cmd = "/sbin/init"
        cmd_list = [DockerTestbed.VIRT, "run", opts, "-v", mount_cfg, "-v", mount_log, "-v", mount_cert,
                    args[0], args[1], "--name", container, "--network", self.network_name,
                    img, cmd]
        if self.args.verbose:
            print(cmd_list)
        resp = Testbed.runshell(cmd_list)
        print(resp.stdout.decode("utf-8") if resp.returncode ==
              0 else resp.stderr.decode("utf-8"))

    def run_container_cmd(self, cmd_line, instance_num):
        #report = dict(fail_count=0, fail_node=[])
        cmd_list = [DockerTestbed.VIRT, "exec", "-it"]
        inst = "{0:03}".format(instance_num)
        container = DockerTestbed.CONTAINER.format(inst)
        cmd_list.append(container)
        cmd_list += cmd_line
        resp = Testbed.runshell(cmd_list)
        if self.args.verbose:
            print(cmd_list)
            print(resp.stdout.decode("utf-8"))
        # if resp.returncode != 0:
        #    report["fail_count"] += 1
        #    report["fail_node"].append("node-{0}".format(inst))
        # rpt_msg = "{0}: {1}/{2} failed\n{3}".format(cmd_line, report["fail_count"],
        #                                            self.range_end - self.range_start,
        #                                            report["fail_node"])
        # print(rpt_msg)

    def run_cmd_on_slice(self, cmd_line, delay=0):
        report = dict(fail_count=0, fail_node=[])
        #for inst in self.seq_list[self.range_start-1:self.range_end]:
        for inst in self.seq_list[self.slice_start:self.slice_end]:
            cmd_list = [DockerTestbed.VIRT, "exec", "-it"]
            inst = "{0:03}".format(inst)
            container = DockerTestbed.CONTAINER.format(inst)
            cmd_list.append(container)
            cmd_list += cmd_line
            resp = Testbed.runshell(cmd_list)
            if self.args.verbose:
                print(cmd_list)
                print(resp.stdout.decode("utf-8"))
            if resp.returncode != 0:
                report["fail_count"] += 1
                report["fail_node"].append("node-{0}".format(inst))
            if delay > 0:
                time.sleep(delay)
        rpt_msg = "{0}: {1}/{2} failed\n{3}".format(cmd_line, report["fail_count"],
                                                    self.slice_end - self.slice_start,
                                                    report["fail_node"])
        print(rpt_msg)

    def pull_image(self):
        cmd_list = [DockerTestbed.VIRT, "pull", Testbed.BF_VIRT_IMG]
        resp = Testbed.runshell(cmd_list)
        if self.args.verbose:
            print(resp)

    def stop_range(self):
        cnt = 0
        cmd_list = [DockerTestbed.VIRT, "kill"]
        #sequence = self.seq_list[self.range_start-1:self.range_end]
        sequence = self.seq_list[self.slice_start:self.slice_end]
        for inst in sequence:
            cnt += 1
            inst = "{0:03}".format(inst)
            container = DockerTestbed.CONTAINER.format(inst)
            cmd_list.append(container)
        if self.args.verbose:
            print(cmd_list)
        resp = Testbed.runshell(cmd_list)
        print(resp.stdout.decode("utf-8") if resp.returncode == 0 else
              resp.stderr.decode("utf-8"))
        print("{0} Docker container(s) terminated".format(cnt))

    def end(self):
        self.run_cmd_on_slice(["systemctl", "stop", "evio"])
        self.stop_range()

    def run_ping(self, target_address):
        report = dict(fail_count=0, fail_node=[])
        for inst in range(self.range_start, self.range_end):
            cmd_list = [DockerTestbed.VIRT, "exec", "-it"]
            inst = "{0:03}".format(inst)
            container = DockerTestbed.CONTAINER.format(inst)
            cmd_list.append(container)
            cmd_list += ["ping", "-c1"]
            cmd_list.append(target_address)
            resp = Testbed.runshell(cmd_list)
            if self.args.verbose:
                print(cmd_list)
                print("ping ", target_address, "\n",
                      resp.stdout.decode("utf-8"))
            if resp.returncode != 0:
                report["fail_count"] += 1
                report["fail_node"].append("node-{0}".format(inst))
        rpt_msg = "ping {0}: {1}/{2} failed\n{3}".format(target_address, report["fail_count"],
                                                         self.range_end - self.range_start,
                                                         report["fail_node"])
        print(rpt_msg)

    def run_arp(self, target_address):
        for inst in range(self.range_start, self.range_end):
            cmd_list = [DockerTestbed.VIRT, "exec", "-it"]
            inst = "{0:03}".format(inst)
            container = DockerTestbed.CONTAINER.format(inst)
            cmd_list.append(container)
            cmd_list += ["arping", "-C1"]
            cmd_list.append(target_address)
            if self.args.verbose:
                print(cmd_list)
            resp = Testbed.runshell(cmd_list)
            print(resp.stdout.decode("utf-8") if resp.returncode == 0 else
                  resp.stderr.decode("utf-8"))

    def run_svc_ctl(self, svc_ctl):
        if svc_ctl == "stop":
            self.run_cmd_on_slice(["systemctl", "stop", "evio"])
        elif svc_ctl == "start":
            self.run_cmd_on_slice(["systemctl", "start", "evio"], 10)
        elif svc_ctl == "restart":
            self.run_cmd_on_slice(["systemctl", "restart", "evio"], 1)
        else:
            print("Invalid service control specified, only accepts start/stop/restart")


def main():  # pylint: disable=too-many-return-statements
    exp = DockerTestbed()

    if exp.args.run and exp.args.end:
        print("Error! Both run and end were specified.")
        return

    if exp.args.info:
        exp.display_current_config()
        return

    if exp.args.setup:
        exp.setup_system()
        return

    if exp.args.pull:
        exp.pull_image()
        return

    if exp.args.clean:
        exp.make_clean()
        return

    if exp.range_end - exp.range_start <= 0:
        print("Invalid range, please fix RANGE_START={0} RANGE_END={1}".
              format(exp.range_start, exp.range_end))
        return

    if exp.args.configure:
        exp.configure()

    if exp.args.run:
        exp.run()
        return

    if exp.args.end:
        exp.end()
        return

    if exp.args.ping:
        exp.run_ping(exp.args.ping)
        return

    if exp.args.arp:
        exp.run_arp(exp.args.arp)
        return

    if exp.args.evio:
        exp.run_svc_ctl(exp.args.evio)
        return

    if exp.args.churn:
        exp.churn(exp.args.churn)
        return

    if exp.args.test:
        exp.run_test()
        return


if __name__ == "__main__":
    main()
