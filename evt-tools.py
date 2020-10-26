import argparse
import sys
sys.path.append('../')
from scripts.Link import Link
import subprocess
import os

SH = "ev-tools.sh"


class EvtTools:
    def __init__(self):
        parser = argparse.ArgumentParser(
            description="A collection of all the tools which can be used to deploy EdgeVPN")
        parser.add_argument("--sync", action="store_true", default=False, dest="sync",
                            help="Syncs the tools repo with the correct version of the tools script."
                                 "You need to clone the evio repository a directory above for this to work.")
        parser.add_argument("--clean", action="store_true", default=False, dest="clean",
                            help="Cleans the code from all the locations to prepare for a fresh installation.")
        parser.add_argument("--deps", action="store_true", default=False, dest="deps",
                            help="Installs system-wide the necessary build tools.")
        parser.add_argument("--src", action="store_true", default=False, dest="src",
                            help="Clones EVIO repo.")
        parser.add_argument("--debpak", action="store_true", default=False, dest="debpak",
                            help="Generates the Debian package.")
        parser.add_argument("--testbed", action="store_true", default=False, dest="testbed",
                            help="Installs required dependencies for a testbed.")
        parser.add_argument("--venv", action="store_true", default=False, dest="venv",
                            help="Setup the virtual environment.")
        parser.add_argument("--xmpp", action="store_true", default=False, dest="xmpp",
                            help="Install openfire server.")
        parser.add_argument("--build_docker", action="store_true", default=False, dest="dkrimg",
                            help="Builds the docker image if you have already built the debian package.")
        parser.add_argument("--build_wrtc", action="store_true", default=False, dest="webrtc",
                            help="Clones and builds the webrtc libraries for ubuntu and returns a debug build.")
        parser.add_argument("--build_wrtc_rel", action="store_true", default=False, dest="webrtc_r",
                            help="Clones and builds the webrtc libraries for ubuntu and returns a release build.")
        parser.add_argument("--build_wrtc_rpi_dbg", action="store_true", default=False, dest="webrtc_r_d",
                            help="Clones and builds the webrtc libraries for raspberry and returns a debug build.")
        parser.add_argument("--build_wrtc_rpi_rel", action="store_true", default=False, dest="webrtc_r_r",
                            help="Clones and builds the webrtc libraries for raspberry and returns a release build.")
        parser.add_argument("--build_tincan", action="store_true", default=False, dest="tincan",
                            help="Builds the tincan debug executable for ubuntu. It assumes you have the webrtc "
                                 "libraries already cloned or built")
        parser.add_argument("--build_tincan_rel", action="store_true", default=False, dest="tincan_r",
                            help="Builds the tincan release executable for ubuntu. It assumes you have the webrtc "
                                 "libraries already cloned or built")
        parser.add_argument("--build_tincan_rpi_dbg", action="store_true", default=False, dest="tincan_r_d",
                            help="Builds the tincan debug executable for raspberry. It assumes you have the webrtc "
                                 "libraries already cloned or built")
        parser.add_argument("--build_tincan_rpi_rel", action="store_true", default=False, dest="tincan_r_r",
                            help="Builds the tincan release executable for raspberry. It assumes you have the webrtc "
                                 "libraries already cloned or built")
        parser.add_argument("--all", action="store_true", default=False, dest="all",
                            help="Setup the whole environment.")
        self.args = parser.parse_args()

    def sync(self):
        link = Link()
        link.sync(None)

    def clean(self):
        if self.check_for_link():
            subprocess.run([SH + " clean"], shell=True)

    def build_tools(self):
        if self.check_for_link():
            subprocess.run([SH + " deps"], shell=True)

    def pull_src(self):
        if self.check_for_link():
            subprocess.run([SH + " src"], shell=True)

    def tincan(self):
        if self.check_for_link():
            subprocess.run([SH + " tincan"], shell=True)

    def debpak(self):
        if self.check_for_link():
            subprocess.run([SH + " debpak"], shell=True)

    def testbed(self):
        if self.check_for_link():
            subprocess.run([SH + " testbed"], shell=True)

    def venv(self):
        if self.check_for_link():
            subprocess.run([SH + " venv"], shell=True)

    def xmpp(self):
        if self.check_for_link():
            subprocess.run([SH + " xmpp"], shell=True)

    def build_docker(self):
        if self.check_for_link():
            subprocess.run([SH + " dkrimg"], shell=True)

    def build_webrtc(self):
        if self.check_for_link():
            subprocess.run([(SH + " build_webrtc")], shell=True)

    def build_webrtc_release_ubuntu(self):
        if self.check_for_link():
            subprocess.run([SH + " build_webrtc_with_release_ubuntu"], shell=True)

    def build_webrtc_debug_raspberry(self):
        if self.check_for_link():
            subprocess.run([SH + " build_webrtc_with_debug_raspberry_pi"], shell=True)

    def build_webrtc_release_raspberry(self):
        if self.check_for_link():
            subprocess.run([SH + " build_webrtc_with_release_raspberry_pi"], shell=True)

    def build_tincan(self):
        if self.check_for_link():
            subprocess.run([SH + " build_tincan"], shell=True)

    def build_tincan_release_ubuntu(self):
        if self.check_for_link():
            subprocess.run([SH + " build_tincan_release_ubuntu"], shell=True)

    def build_tincan_debug_raspberry(self):
        if self.check_for_link():
            subprocess.run([SH + " build_tincan_debug_raspberry"], shell=True)

    def build_tincan_release_raspberry(self):
        if self.check_for_link():
            subprocess.run([SH + " build_tincan_release_raspberry"], shell=True)

    def check_for_link(self):
        if os.path.isfile(SH):
            return True
        else:
            print("Please run evt --sync and then retry the command.")

    def all(self):
        if self.check_for_link():
            subprocess.run([SH + " all"], shell=True)

def main():
    tools = EvtTools()

    if tools.args.clean:
        tools.clean()
        return

    if tools.args.src:
        tools.pull_src()
        return

    if tools.args.tincan:
        tools.build_tincan()
        return

    if tools.args.debpak:
        tools.debpak()
        return

    if tools.args.testbed:
        tools.testbed()
        return
    
    if tools.args.venv:
        tools.venv()
        return

    if tools.args.xmpp:
        tools.xmpp()
        return

    if tools.args.dkrimg:
        tools.build_docker()
        return

    if tools.args.webrtc:
        tools.build_webrtc()
        return

    if tools.args.webrtc_r:
        tools.build_webrtc_release_ubuntu()
        return

    if tools.args.webrtc_r_d:
        tools.build_webrtc_debug_raspberry()
        return

    if tools.args.webrtc_r_r:
        tools.build_webrtc_release_raspberry()
        return

    if tools.args.tincan_r:
        tools.build_tincan_release_ubuntu()
        return

    if tools.args.tincan_r_d:
        tools.build_tincan_debug_raspberry()
        return

    if tools.args.tincan_r_r:
        tools.build_tincan_release_raspberry()
        return

    if tools.args.all:
        tools.all()
        return

    if tools.args.sync:
        tools.sync()
        return

if __name__ == "__main__":
    main()
