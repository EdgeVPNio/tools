# EdgeVPNio DEBIAN PACKAGE

The Debian package installs EdgeVPNio (evio) as a systemd service and is supported in Ubuntu 18.04 and Raspberry Pi Raspbian OS. Use the following procedure to create a new installer package.

1. Clone the `tools` repo and use `tools/debian-package` as your base directory.
2. Copy the `tincan` executable, and the contents of the `controller` folder into `evio/opt/evio`.
3. Copy `config.json`, the template or completed file, into `evio/etc/opt/evio`.
4. Execute `./deb-gen` to create the `evio.deb` installer package.

Installation creates the following files and directories:

1. `/opt/evio/tincan`
2. `/opt/evio/controller/`
3. `/etc/opt/evio/config.json`
4. `/etc/systemd/system`
5. `/var/logs/evio/tincan_log`
6. `/var/logs/evio/ctrl.log`

To install EdgeVPNio invoke `sudo apt install -y <path/to/installer>/evio.deb`.  
After installation but before starting evio, complete `config.json` by adding the XMPP credentials, setting the IP address, and applying other configurations as needed.  
Then start evio using `sudo systemctl start evio`.  
Additionally, use `systemctl` to start/stop/restart/status evio.

EdgeVPNio is configured to be started automatically on reboot.
