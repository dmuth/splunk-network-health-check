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


while true
do
	./icmp_drop.sh
	sleep 13
	./icmp_allow.sh
	sleep 13
done



