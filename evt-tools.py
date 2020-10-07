import argparse
import sys
sys.path.append('../')
from scripts.Link import Link
import subprocess


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
                            help="Installs the required build tools.")
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
        subprocess.run(["ev-tools.sh clean"], shell=True)

    def build_tools(self):
        subprocess.run(["ev-tools.sh deps"], shell=True)

    def pull_src(self):
        subprocess.run(["ev-tools.sh src"], shell=True)

    def tincan(self):
        subprocess.run(["ev-tools.sh tincan"], shell=True)

    def debpak(self):
        subprocess.run(["ev-tools.sh debpak"], shell=True)

    def testbed(self):
        subprocess.run(["ev-tools.sh testbed"], shell=True)

    def venv(self):
        subprocess.run(["ev-tools.sh venv"], shell=True)

    def xmpp(self):
        subprocess.run(["ev-tools.sh xmpp"], shell=True)

    def build_docker(self):
        subprocess.run(["ev-tools.sh dkrimg"], shell=True)

    def build_webrtc(self):
        subprocess.run(["ev-tools.sh build_webrtc"], shell=True)

    def build_webrtc_release_ubuntu(self):
        subprocess.run(["ev-tools.sh build_webrtc_with_release_ubuntu"], shell=True)

    def build_webrtc_debug_raspberry(self):
        subprocess.run(["ev-tools.sh build_webrtc_with_debug_raspberry_pi"], shell=True)

    def build_webrtc_release_raspberry(self):
        subprocess.run(["ev-tools.sh build_webrtc_with_release_raspberry_pi"], shell=True)

    def build_tincan(self):
        subprocess.run(["ev-tools.sh build_tincan"], shell=True)

    def build_tincan_release_ubuntu(self):
        subprocess.run(["ev-tools.sh build_tincan_release_ubuntu"], shell=True)

    def build_tincan_debug_raspberry(self):
        subprocess.run(["ev-tools.sh build_tincan_debug_raspberry"], shell=True)

    def build_tincan_release_raspberry(self):
        subprocess.run(["ev-tools.sh build_tincan_release_raspberry"], shell=True)

    def all(self):
        subprocess.run(["ev-tools.sh all"], shell=True)

def main():
    tools = EvtTools()

    if tools.args.clean:
        tools.clean()
        return

    if tools.args.src:
        tools.pull_src()
        return

    if tools.args.tincan:
        tools.tincan()
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

    if tools.args.tincan:
        tools.build_tincan()
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
