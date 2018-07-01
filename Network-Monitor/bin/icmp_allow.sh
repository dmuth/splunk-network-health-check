#!/bin/bash
#
# Allow all ICMP traffic.
#

set -e # Errors are fatal


iptables -D OUTPUT -p icmp -j DROP
iptables -D OUTPUT -p udp --dport 53 -j DROP
iptables -D OUTPUT -p tdp --dport 53 -j DROP

echo "#"
echo "# Now allowing all ICMP and DNS traffic"
echo "#"

