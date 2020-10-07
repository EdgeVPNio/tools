# EdgeVPNio tools

Various management and configuration tools used with EdgeVPNio software development.

## Using the repository
One the same directory level as evio clone the repository with:
``` 
git clone https://github.com/EdgeVPNio/tools.git
```

## Setup
To setup running the evt tool use the following command :
```
source setup-evt.sh
```

## Usage
Run the command to view all options:
```
evt -h
```
```
usage: evt-tools.py [-h] [--sync] [--clean] [--deps] [--src] [--debpak] [--testbed] [--venv] [--xmpp] [--build_docker] [--build_webrtc] [--build_webrtc_release]
                    [--build_webrtc_raspberry_debug] [--build_webrtc_raspberry_release] [--build_tincan] [--build_tincan_release] [--build_tincan_raspberry_debug]
                    [--build_tincan_raspberry_release] [--all]

A collection of all the tools which can be used to deploy EdgeVPN

optional arguments:
  -h, --help            show this help message and exit
  --sync                Syncs the tools repo with the correct version of the tools script.You need to clone the evio repository a directory above for this to work.
  --clean               Cleans the code from all the locations to prepare for a fresh installation.
  --deps                Installs system-wide the necessary build tools.
  --src                 Clones EVIO repo.
  --debpak              Generates the Debian package.
  --testbed             Installs required dependencies for a testbed.
  --venv                Setup the virtual environment.
  --xmpp                Install openfire server.
  --build_docker        Builds the docker image if you have already built the debian package.
  --build_webrtc        Clones and builds the webrtc libraries for ubuntu and returns a debug build.
  --build_webrtc_release
                        Clones and builds the webrtc libraries for ubuntu and returns a release build.
  --build_webrtc_raspberry_debug
                        Clones and builds the webrtc libraries for raspberry and returns a debug build.
  --build_webrtc_raspberry_release
                        Clones and builds the webrtc libraries for raspberry and returns a release build.
  --build_tincan        Builds the tincan debug executable for ubuntu. It assumes you have the webrtc libraries already cloned or built
  --build_tincan_release
                        Builds the tincan release executable for ubuntu. It assumes you have the webrtc libraries already cloned or built
  --build_tincan_raspberry_debug
                        Builds the tincan debug executable for raspberry. It assumes you have the webrtc libraries already cloned or built
  --build_tincan_raspberry_release
                        Builds the tincan release executable for raspberry. It assumes you have the webrtc libraries already cloned or built
  --all                 Setup the whole environment.
```
```
evt --sync
```
## TO DO
Move to one output folder. Run sync before any command.
