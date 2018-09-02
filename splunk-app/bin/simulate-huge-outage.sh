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


TIME=3600
#TIME=5 # Debugging
#TIME=30 # Debugging

echo "# Simulating a huge network outage..."
./simulate-network.sh --time ${TIME} --latency 1000 --jitter 100 --distribution pareto --loss 90


