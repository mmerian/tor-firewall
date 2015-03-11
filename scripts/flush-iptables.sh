#!/usr/bin/env bash

#
# Clear all iptables rules
#

# Check that we run as root
if [[ `id -u` -ne 0 ]]; then
	echo 'This script must be run as root'
	exit 1
fi

IPT=/sbin/iptables

$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT
