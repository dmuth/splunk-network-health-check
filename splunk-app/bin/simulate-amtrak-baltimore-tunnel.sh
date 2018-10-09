#!/bin/bash
#
# Simulate a tunnel by baltimore on Amtrak.
# This included like a 3 minute blackout of total packet less
#

# Errors are fatal
set -e

#
# Change to the directory of this script
#
pushd $(dirname $0) > /dev/null


TIME_SURFACE=600
#TIME_SURFACE=5 # Debugging
TIME_TUNNEL=180
#TIME_TUNNEL=10 # Debugging

function surface() {

	echo "# Simulating surface conditions..."
	./simulate-network.sh --time ${TIME_SURFACE} --latency 200 --jitter 50 --distribution pareto --loss 5

}


function tunnel() {
	echo "# Simulating the tunnel conditions..."
	./simulate-network.sh --time ${TIME_TUNNEL} --loss 100
}

surface
tunnel
surface



