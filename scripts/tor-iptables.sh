#!/usr/bin/env bash

#
# Setup full tor system
#

# Check that we run as root
if [[ `id -u` -ne 0 ]]; then
    echo 'This script must be run as root'
    exit 1
fi

# Tor user id
_tor_uid=`cat /etc/passwd|grep tor|cut -f 1 -d :`
if [ -z "$_tor_uid" ]; then
    $_tor_uid=tor
fi

# i2p user id
_i2p_uid=`cat /etc/passwd|grep i2p|cut -f 1 -d :`
if [ -z "$_i2p_uid" ]; then
    $_i2p_uid=i2p
fi

_trans_port=9040

# Destinations that will not
# be routed through tor
_non_tor="192.168.0.0/255.255.0.0
10.0.0.0/255.0.0.0
172.16.0.0/255.240.0.0
127.0.0.0/255.0.0.0"

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

# Allow established connections
$IPT -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow traffic on loopback interface
$IPT -A INPUT -i lo -j ACCEPT

# Allow all tor traffic
$IPT -t nat -A OUTPUT -m owner --uid-owner $_tor_uid -j RETURN

# Allow all i2p traffic
$IPT -t nat -A OUTPUT -m owner --uid-owner $_i2p_uid -j RETURN

# Route DNS queries through tor
$IPT -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 53

# Allow ICMP requests, they are not routed by tor
$IPT -t nat -A OUTPUT -p icmp -j RETURN

# Allow direct destinations
for i in $_non_tor; do
    $IPT -t nat -A OUTPUT -d $i -j RETURN
    $IPT -A OUTPUT -d $i -j RETURN
done

# Allow UDP, since tor can't handle it
$IPT -t nat -A OUTPUT -p udp -j ACCEPT

# Route all traffic through tor
$IPT -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $_trans_port

# Allow ICMP requests
$IPT -A OUTPUT -p icmp -j RETURN

$IPT -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,FIN ACK,FIN -j LOG --log-prefix "Transproxy leak blocked: " --log-uid
$IPT -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,RST ACK,RST -j LOG --log-prefix "Transproxy leak blocked: " --log-uid
$IPT -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,FIN ACK,FIN -j DROP
$IPT -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,RST ACK,RST -j DROP

$IPT -A OUTPUT -m owner --uid-owner $_tor_uid -j ACCEPT
$IPT -A OUTPUT -m owner --uid-owner $_i2p_uid -j ACCEPT

$IPT -A OUTPUT -p udp -j ACCEPT
$IPT -A OUTPUT -j REJECT
