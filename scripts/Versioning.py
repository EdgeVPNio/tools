import os
import time
import subprocess
import fileinput
import sys
import shutil
from tool_config import CONTROL_VER as control
from tool_config import OFFICIAL as official
from tool_config import MAJOR_VER as mjr
from tool_config import MINOR_VER as mnr
from tool_config import REVISION_VER as rvn

n = len(sys.argv)
class Versioning:
    def changeVersionInTincan(self):
        major = mjr
        minor = mnr
        revision = rvn
        if official:
            ver = str(mjr) + "." + str(mnr) + "." + str(revision)
        else:
            build = int(str(time.time())[-6:])
            ver = str(mjr) + "." + str(mnr) + "." + str(revision) + "." + str(build)

        wd = os.getcwd()
        location1 = os.environ['HOME'] + "/workspace/EdgeVPNio/evio/tincan/trunk/include"
        location = './scripts'
        os.chdir(location)
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
        with open('./tincan_version.h', 'w') as t_file:
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

        src = os.path.join(os.getcwd(), 'tincan_version.h')
        filename = os.path.basename(src)
        dest = os.path.join(location1, filename)
        shutil.move(src, dest)
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
        location2 = os.environ['HOME'] + "/workspace/EdgeVPNio/evio/controller/framework"
        with open('Version.py', 'w') as c_file:
            c_file.write(str1)
            c_file.write("\n")
            c_file.write("\n")
            c_file.write("EVIO_VER_MJR = " + str(mjr) + "\n")
            c_file.write("EVIO_VER_MNR = " + str(mnr) + "\n")
            c_file.write("EVIO_VER_REV = " + str(revision) + "\n")
            c_file.write("EVIO_VER_BLD = " + str(build) + "\n")
            c_file.write("EVIO_VER_CTL = " + str(control) + "\n")
        src1 = os.path.join(os.getcwd(), 'Version.py')
        filename1 = os.path.basename(src1)
        dest1 = os.path.join(location2, filename1)
        shutil.move(src1, dest1)
        os.chdir("../debian-package")
        subprocess.run("./debian-config")
        for line in fileinput.input('./edge-vpnio/DEBIAN/control', inplace=True):
            if line.strip().startswith('Version'):
                if official:
                   line = 'Version : ' + ver + '\n'
                else:
                   line = 'Version : ' + ver + '-dev\n'
            sys.stdout.write(line)
        os.chdir(wd)

if __name__ == '__main__':
    version = Versioning()

    version.changeVersionInTincan()

