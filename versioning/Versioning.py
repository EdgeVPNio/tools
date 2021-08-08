import argparse
import os
import time
import subprocess
import fileinput
import sys
import shutil
from tool_config import CONTROL_VER as control
from tool_config import OFFICIAL as official
from tool_config import MAJOR_VER as major
from tool_config import MINOR_VER as minor
from tool_config import REVISION_VER as revision

class Versioning():
    LICENSE = "{1}{0} EdgeVPNio\n{0} Copyright 2020, University of Florida\n{0}\n" \
               "{0} Permission is hereby granted, free of charge, to any person obtaining a copy\n" \
               "{0} of this software and associated documentation files (the \"Software\"), to deal\n" \
               "{0} in the Software without restriction, including without limitation the rights\n" \
               "{0} to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n" \
               "{0} copies of the Software, and to permit persons to whom the Software is\n" \
               "{0} furnished to do so, subject to the following conditions:\n" \
               "{0}\n" \
               "{0} The above copyright notice and this permission notice shall be included in\n" \
               "{0} all copies or substantial portions of the Software.\n" \
               "{0}\n" \
               "{0} THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n" \
               "{0} IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n" \
               "{0} FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n" \
               "{0} AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n" \
               "{0} LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n" \
               "{0} OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n" \
               "{0} THE SOFTWARE.\n" \
               "{2}"
    tincan_version_template = LICENSE.format("*", "/*\n", "*/\n") + \
               "#ifndef TINCAN_VERSION_H_\n" \
                "#define TINCAN_VERSION_H_\n" \
                "namespace tincan\n" \
                "{{\n" \
                "    static const uint16_t kTincanVerMjr = {0};\n" \
                "    static const uint16_t kTincanVerMnr = {1};\n" \
                "    static const uint16_t kTincanVerRev = {2};\n" \
                "    static const uint16_t kTincanVerBld = {3};\n" \
                "    static const uint8_t kTincanControlVer = {4};\n" \
                "}} // namespace tincan\n" \
                "#endif // TINCAN_VERSION_H_\n"

    controller_version_template = LICENSE.format("#", "", "\n") + \
        "EVIO_VER_MJR = {0}\n" \
        "EVIO_VER_MNR = {1}\n" \
        "EVIO_VER_REV = {2}\n" \
        "EVIO_VER_BLD = {3}\n" \
        "EVIO_VER_CTL = {4}\n" 

    build_num_filename = "/var/tmp/evio_build_number"

    def __init__(self):
        parser = argparse.ArgumentParser(description="Generates and manages version info and files for Evio build")
        parser.add_argument("--workspace_root", action="store", dest="wrksproot",
                            help="Absolute pathname to the workspace directory.")
        parser.add_argument("--version", action="store_true", default=False, dest="version",
                            help="Prints the current version to stdout.")                            
        parser.add_argument("--build_num", action="store_true", default=False, dest="build_num",
                            help="Prints the current build number to stdout.")
        parser.add_argument("--next_build_num", action="store_true", default=False, dest="next_build_num",
                            help="Increments and prints the build number to stdout.")                            
        parser.add_argument("-q", action="store_true", default=False, dest="quiet",
                            help="Nothing is printed stdout.")                            
        parser.add_argument("-verbose", action="store_true", default=False, dest="verbose",
                            help="Extra info printed to stdout.")
        parser.add_argument("--gen_version_files", action="store_true", default=False, dest="gen_version_files",
                            help="Generates tincan_version.h and Version.py with appropriate values.")

        self.args = parser.parse_args()
        if not self.args.wrksproot:
            self.args.wrksproot = os.getcwd()
        self._tincan_version_fqn = os.path.join(self.args.wrksproot, "EdgeVPNio/evio/tincan/trunk/include/tincan_version.h")
        self._controller_version_fqn = os.path.join(self.args.wrksproot, "EdgeVPNio/evio/controller/framework/Version.py")
        self._version = "{0}.{1}.{2}".format(major, minor, revision)
        self._build_num = 0
        self._load_build_number()
        if not official:
            self._version += ".{}-dev".format(self._build_num)
        
    def generate_tincan_ver_header(self):
        tincan_version_str = self.tincan_version_template.format(major, minor, revision, self._build_num, control)
        if self.args.verbose:
            print("Generating ", self._tincan_version_fqn)
        with open(self._tincan_version_fqn, 'w') as tvfl:
            tvfl.write(tincan_version_str)

    def generate_controller_version_file(self):
        controller_version_str = self.controller_version_template.format(major, minor, revision, self._build_num, control)
        if self.args.verbose:
            print("Generating ", self._controller_version_fqn)
        with open(self._controller_version_fqn, 'w') as cvfl:
            cvfl.write(controller_version_str)
    
    @property
    def build_number(self):
        return self._build_num

    @property
    def version_string(self):
        return self._version

    @property
    def next_build_number(self):
        self._next_build_number()
        return self._build_num

    def _load_build_number(self):
        try:
            with open(self.build_num_filename, 'r') as bnfl:
                self._build_num = int(bnfl.readline())
        except FileNotFoundError:
            self._build_num = 0
            self._next_build_number()
   
    def _next_build_number(self):
        self._build_num = self._build_num + 1 if self._build_num < 65536 else 1
        with open(self.build_num_filename, 'w') as bnfl:
            bnfl.write(str(self._build_num))

def main(): # pylint: disable=too-many-return-statements
    app = Versioning()

    if app.args.version:
      if not app.args.quiet:
        print(app.version_string)
      return
    if app.args.build_num:
      if not app.args.quiet:
        print(app.build_number)
      return
    if app.args.next_build_num:
      build_number = app.next_build_number
      if not app.args.quiet:
        print(build_number)
      return
    if app.args.gen_version_files:
        app.generate_controller_version_file()
        app.generate_tincan_ver_header()
        return
    
if __name__ == '__main__':
    main()
