#!/bin/bash
#
# Drop all ICMP traffic. This is useful for testing.
#

set -e # Errors are fatal


iptables -A OUTPUT -p icmp -j DROP
echo "#"
echo "# Now dropping all ICMP traffic"
echo "#"

