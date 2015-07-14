#!/bin/bash
#
# iptables example configuration script
#
# Flush all current rules from iptables
#
 echo "0" > /proc/sys/net/ipv4/ip_forward
 iptables -F
 iptables -F -t nat
#

#
# PORTS open to RHIT campus
#
 iptables -A INPUT -p tcp -s 137.112.0.0/16 --dport 22    -j ACCEPT
 iptables -A INPUT -p tcp                   --dport 80    -j ACCEPT
 iptables -A INPUT -p tcp 		    --dport 443   -j ACCEPT
 iptables -A INPUT -p tcp                   --dport 8000  -j ACCEPT

#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
 iptables -P INPUT DROP
 iptables -P FORWARD DROP
 iptables -P OUTPUT ACCEPT
#
# Set access for localhost
#
 iptables -A INPUT -i lo -j ACCEPT
#
# Accept packets belonging to established and related connections
#
 iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#
# Save settings
#
/usr/sbin/service iptables save
iptables-save >> /etc/iptables/rules.v4
#
# List rules
#
echo "Firewall rules"
 iptables -L -v

echo "NAT Rules"
 iptables -t nat -L -n -v

