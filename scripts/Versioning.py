import os
import time
import fileinput
import sys
from scripts.tool_config import CONTROL_VER as control
from scripts.tool_config import OFFICIAL as official
from scripts.tool_config import MAJOR_VER as mjr
from scripts.tool_config import MINOR_VER as mnr
from scripts.tool_config import REVISION_VER as rvn


class Versioning:
    def changeVersionInTincan(self, major, minor, revision, build):
        major = mjr
        minor = mnr
        revision = rvn
        if official:
            build = 0
            ver = str(mjr) + "." + str(mnr) + "." + str(revision)
        else:
            build = int(time.time())
            ver = str(mjr) + "." + str(mnr) + "." + str(revision) + "." + str(build)

        wd = os.getcwd()
        location1 = "~/workspace/EdgeVPNIO/evio/tincan/trunk/include/tincan_version.h"
        #location = '.'
        os.chdir(location1)
        # version_h_r = open("tincan_version.h", 'r').read()
        # version_h_w = open("tincan_version.h", 'w')
        # m = version_h_r.replace("static const uint16_t kTincanVerMjr = 0;", "static const uint16_t kTincanVerMjr = " + major + ";")
        # m = version_h_r.replace("static const uint16_t kTincanVerMnr = 0;", "static const uint16_t kTincanVerMnr = " + minor + ";")
        # m = version_h_r.replace("static const uint16_t kTincanVerRev = 0;", "static const uint16_t kTincanVerRev = " + revision + ";")
        # m = version_h_r.replace("static const uint16_t kTincanVerBld = 0;", "static const uint16_t kTincanVerBld = " + build + ";")
        # version_h_w.write(m)
        # os.chdir(wd)
        str1 = "/*\n* EdgeVPNio\n* Copyright 2020, University of Florida\n*\n" \
               "* Permission is hereby granted, free of charge, to any person obtaining a copy\n" \
               "* of this software and associated documentation files (the \"Software\"), to deal\n" \
               "* in the Software without restriction, including without limitation the rights\n" \
               "* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n" \
               "* copies of the Software, and to permit persons to whom the Software is\n" \
               "* furnished to do so, subject to the following conditions:\n" \
               "*\n" \
               "* The above copyright notice and this permission notice shall be included in\n" \
               "* all copies or substantial portions of the Software.\n" \
               "*\n" \
               "* THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n" \
               "* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n" \
               "* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n" \
               "* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n" \
               "* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n" \
               "* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n" \
               "* THE SOFTWARE.\n" \
               "*/\n"
        with open('tincan_version.h', 'w') as t_file:
            t_file.write(str1)
            t_file.write("#ifndef TINCAN_VERSION_H_\n")
            t_file.write("#define TINCAN_VERSION_H_\n")
            t_file.write("namespace tincan\n")
            t_file.write("{\n")
            t_file.write("    static const uint16_t kTincanVerMjr = " + str(major) + ";\n")
            t_file.write("    static const uint16_t kTincanVerMnr = " + str(minor) + ";\n")
            t_file.write("    static const uint16_t kTincanVerRev = " + str(revision) + ";\n")
            t_file.write("    static const uint16_t kTincanVerBld = " + str(build) + ";\n")
            t_file.write("    static const uint8_t kTincanControlVer = " + str(control) + ";\n")
            t_file.write("} // namespace tincan\n")
            t_file.write("#endif // TINCAN_VERSION_H_")
        os.replace('tincan_version.h', location1)
        str1 = "#\n# EdgeVPNio\n# Copyright 2020, University of Florida\n#\n" \
               "# Permission is hereby granted, free of charge, to any person obtaining a copy\n" \
               "# of this software and associated documentation files (the \"Software\"), to deal\n" \
               "# in the Software without restriction, including without limitation the rights\n" \
               "# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n" \
               "# copies of the Software, and to permit persons to whom the Software is\n" \
               "# furnished to do so, subject to the following conditions:\n" \
               "#\n" \
               "# The above copyright notice and this permission notice shall be included in\n" \
               "# all copies or substantial portions of the Software.\n" \
               "#\n" \
               "# THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n" \
               "# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n" \
               "# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n" \
               "# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n" \
               "# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n" \
               "# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n" \
               "# THE SOFTWARE.\n" \
               "#/\n"
        location2 = "~/workspace/EdgeVPNIO/evio/controller/framework/Version.py"
        with open('Version.py', 'w') as c_file:
            c_file.write(str1)
            c_file.write("\n")
            c_file.write("\n")
            c_file.write("EVIO_VER_MJR = " + str(mjr) + "\n")
            c_file.write("EVIO_VER_MNR = " + str(mnr) + "\n")
            c_file.write("EVIO_VER_REV = " + str(revision) + "\n")
            c_file.write("EVIO_VER_BLD = " + str(build) + "\n")
            c_file.write("EVIO_VER_CTL = " + str(control) + "\n")
        os.replace('Version.py', location2)
        os.chdir(wd)
        os.chdir("../debian-package")
        for line in fileinput.input('./deb-gen', inplace=True):
            if line.strip().startswith('Version'):
                if official:
                    line = 'Version : ' + ver + '\n'
                else:
                    line = 'Version : ' + ver + '-dev\n'
            sys.stdout.write(line)
    #os.replace('./temp', './deb-gen')
        # os.rename(r'./temp', r'./deb-gen')


if __name__ == '__main__':
    version = Versioning()
    version.changeVersionInTincan(20, 10, 0, 192385)
