# tor-firewall

This repo holds shell scripts that create iptable rules for routing a computer traffic through tor.

The code assumes that you already have a running tor instance on your computer.

The etc/tor/torrc file contains the required tor configuration directives for the iptables rules to run.

The etc/init.d/tor-firewall and etc/systemd/system/tor-firewall.service are respectively the init and systemd file for running the tor firewall as a system service (eg : service tor-firewall start/stop/restart).

## Installing

Copy the usr/local/scripts/* files to /usr/local/scripts as root on your computer.
Change your torrc file according to the provided torrc file

Either copy etc/init.d/tor-firewall or etc/systemd/system/tor-firewall.service the their respective folders.

Optionnally add tor-firewall to system startup.
