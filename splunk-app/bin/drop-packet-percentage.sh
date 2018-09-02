#!/bin/bash
#
# This script is used to drop a percentage of packets for a certain amount of time
#

set -e

if test ! "$3"
then
	echo "! "
	echo "! Syntax: $0 percent period num_loops"
	echo "! "
	echo "!	percent - Percent chance that packets will be dropped"
	echo "!	period - How long to drop/not drop packets for"
	echo "!	num_loops - How many loops to go through?"
	echo "! "
	exit 1
fi

PERCENT=$1
PERIOD=$2
NUM_LOOPS=$3

#
# Drop outbound ICMP and DNS traffic to simulate a total network outage.
#
function drop_traffic() {

	iptables -A OUTPUT -p icmp -j DROP
	iptables -A OUTPUT -p udp --dport 53 -j DROP
	iptables -A OUTPUT -p tcp --dport 53 -j DROP

} # End of function drop_traffic()


#
# Allow ICMP and DNS traffic again.
#
function allow_traffic() {

	iptables -D OUTPUT -p icmp -j DROP
	iptables -D OUTPUT -p udp --dport 53 -j DROP
	iptables -D OUTPUT -p tcp --dport 53 -j DROP

} # End of function allow_traffic()


#
# Nuke our output chain.
#
function init() {

	iptables -F OUTPUT

} # End of init()


echo "# "
echo "# Starting run to drop random traffic!"
echo "# "
echo "# Percent of traffic dropped: ${PERCENT}%"
echo "# Period to drop/not drop traffic for: ${PERIOD}"
echo "# Number of loops: ${NUM_LOOPS}"
echo "# "


init

NUM_LOOPS_LEFT=$NUM_LOOPS

while test ${NUM_LOOPS_LEFT} -gt 0
do

	CHANCE=$(( $RANDOM % 100 + 1 ))

	if test $CHANCE -le $PERCENT
	then
		echo "# Rolled ${CHANCE}/${PERCENT}, dropping traffic!"
		drop_traffic
		#iptables -L OUTPUT -n # Debugging
		echo "# Sleeping for ${PERIOD} seconds..."
		sleep $PERIOD
		allow_traffic
		#iptables -L OUTPUT -n # Debugging

	else 
		echo "# Rolled ${CHANCE}/${PERCENT}, not dropping traffic!"
		echo "# Sleeping for ${PERIOD} seconds..."
		sleep $PERIOD

	fi

	NUM_LOOPS_LEFT=$(( $NUM_LOOPS_LEFT - 1 ))

done

init

echo "# Done!"


