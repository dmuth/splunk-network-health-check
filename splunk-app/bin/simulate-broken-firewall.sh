#!/bin/bash
#
# Simulate a broken firewall I once spotted!
# Packets were being dropped in an "on again, off again" fashion.
#

# Errors are fatal
set -e

TIME=600

#
# Change to the directory of this script
#
pushd $(dirname $0) > /dev/null


function cycle() {
	echo "# Simulating firewall issue..."
	./simulate-network.sh --time ${TIME} --latency 400 --jitter 50 --distribution pareto --loss 80
	echo "# Back to normal! (for the next ${TIME} seconds...)"
	sleep ${TIME}
}

echo "# "
echo "# Starting cycle of network conditions..."
echo "# "
while true
do
	echo "# "
	echo "# New cycle starting, press CTRL-C to stop!"
	echo "# "
	cycle

done


