#!/bin/bash

# Errors are fatal
set -e

LATENCY="100"
JITTER="10"
LATENCY_CORRELATION="50"
LATENCY_DISTRIBUTION="normal"
LOSS="10"
TIME=10


# --latency
# --jitter
# --latency-distribution
# --latency-correlation
# --loss
# --time


function init() {
	echo "# "
	echo "# Resetting network settings..."
	echo "# "
	tc qdisc replace dev eth0 root noqueue
}


#
# If we exit early, reset everything.
#
trap init SIGINT SIGTERM

init

CMD="tc qdisc replace dev eth0 root netem delay ${LATENCY}ms ${JITTER}ms ${LATENCY_CORRELATION}% distribution ${LATENCY_DISTRIBUTION} loss ${LOSS}%"

echo "# "
echo "# Network Simulation"
echo "# =================="
echo "# "
echo "# Latency: ${LATENCY} ms"
echo "# Latency Jitter: ${JITTER} ms"
echo "# Latency Correlation: ${LATENCY_CORRELATION}%"
echo "# Latency Distribution: ${LATENCY_DISTRIBUTION}"
echo "# Packet Loss: ${LOSS}%"
echo "# Time: ${TIME} seconds"
echo "# "
echo "# Command: ${CMD}"
echo "# "

$CMD
echo "# Network settings applied!  Not sleeping for ${TIME} seconds..."
sleep $TIME

init

echo "# Done!"


