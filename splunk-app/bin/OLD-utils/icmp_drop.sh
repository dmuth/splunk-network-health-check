#!/bin/bash
#
# Drop all ICMP traffic. This is useful for testing.
#

set -e # Errors are fatal


iptables -A OUTPUT -p icmp -j DROP
iptables -A OUTPUT -p udp --dport 53 -j DROP
iptables -A OUTPUT -p tcp --dport 53 -j DROP

echo "#"
echo "# Now dropping all ICMP and DNS traffic"
echo "#"

