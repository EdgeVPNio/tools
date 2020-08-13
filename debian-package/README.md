# EdgeVPNio DEBIAN PACKAGE

The Debian package installs EdgeVPNio (evio) as a systemd service and is supported in Ubuntu 18.04 and Raspberry Pi Raspbian OS. Use the following procedure to create a new installer package.

1. Clone the `tools` repo and use `tools/debian-package` as your base directory.
2. Copy the `tincan` executable, and the contents of the `controller` folder into `edge-vpnio/opt/edge-vpnio`.
3. Copy `config.json`, the template or completed file, into `edge-vpnio/etc/opt/edge-vpnio`.
4. Execute `./deb-gen` to create the `edge-vpnio.deb` installer package.

Installation creates the following files and directories:

1. `/opt/edge-vpnio/tincan`
2. `/opt/edge-vpnio/controller/`
3. `/etc/opt/edge-vpnio/config.json`
4. `/etc/systemd/system`
5. `/var/logs/edge-vpnio/tincan_log`
6. `/var/logs/edge-vpnio/ctrl.log`

To install EdgeVPNio invoke `sudo apt install -y <path/to/installer>/edge-vpnio.deb`.  
After installation but before starting evio, complete `config.json` by adding the XMPP credentials, setting the IP address, and applying other configurations as needed.  
Then start evio using `sudo systemctl start evio`.  
Additionally, use `systemctl` to start/stop/restart/status evio.

EdgeVPNio is configured to be started automatically on reboot.
