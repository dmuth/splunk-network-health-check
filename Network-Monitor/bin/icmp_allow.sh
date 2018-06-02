#!/bin/bash
#
# Allow all ICMP traffic.
#

set -e # Errors are fatal


iptables -D OUTPUT -p icmp -j DROP
echo "#"
echo "# Now allowing all ICMP traffic"
echo "#"

