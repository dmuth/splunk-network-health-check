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

NUM_SECS_ALLOW=10
NUM_SECS_DROP=2


while true
do

	./icmp_drop.sh
	echo "#"
	echo "# Sleeping for ${NUM_SECS_DROP} seconds..."
	echo "#"
	sleep $NUM_SECS_DROP

	./icmp_allow.sh
	echo "#"
	echo "# Sleeping for ${NUM_SECS_ALLOW} seconds..."
	echo "#"
	sleep $NUM_SECS_ALLOW

done



