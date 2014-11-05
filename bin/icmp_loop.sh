#!/bin/bash
#
# Loop through toggling states
#

set -e # Errors are fatal

#
# Change to the location of this script.
#
pushd `dirname $0` > /dev/null


echo "#"
echo "# Looping forever between ICMP states."
echo "# Hit ^C to exit."
echo "# Be sure to re-enable ICMP after existing!"
echo "#"

#
# I recommend prime numbers so that the results change slightly for each interval.
#
NUM_SECS=3
#NUM_SECS=13
#NUM_SECS=79


while true
do

	./icmp_drop.sh
	echo "#"
	echo "# Sleeping for ${NUM_SECS} seconds..."
	echo "#"
	sleep $NUM_SECS

	./icmp_allow.sh
	echo "#"
	echo "# Sleeping for ${NUM_SECS} seconds..."
	echo "#"
	sleep $NUM_SECS

done



