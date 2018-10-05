#!/bin/bash

# Errors are fatal
set -e

LATENCY="100"
JITTER="10"
LATENCY_CORRELATION="0"
LATENCY_DISTRIBUTION="normal"
LOSS="10"
LOSS_CORRELATION=25
TIME=10

function print_syntax() {
	echo "! "
	echo "! Syntax: $0 [ --latency num ] [ --jitter num ] [ --distribution normal|pareto|paretonormal ] [ --correlation num ] [ --loss num ] [ --loss-correlation num ] [ --time num ]"
	echo "! "
	echo "!	--latency Latency to add to packets (in milliseconds)"
	echo "!	--jitter Jitter to add to the latency (in milliseconds)"
	echo "!	--distribution This can be normal, pareto, or paretonormal"
	echo "!	--correlation Percentage chance of previous packet affecting current packet"
	echo "!	--loss Percentage of packets lost"
	echo "!	--loss-correlation percent to correlate with drop decision for previous packet."
	echo "!	--time How many seconds to use these settings for"
	echo "! "
	exit 1
}


function parse_args() {

	while test "$1"
	do

		ARG=$1
		ARG_NEXT=$2
		shift

		if test "$ARG" == "-h" -o "$ARG" == "--help"
		then
			print_syntax

		elif test "$ARG" == "--latency"
		then
			LATENCY=$ARG_NEXT
			shift

		elif test "$ARG" == "--jitter"
		then
			JITTER=$ARG_NEXT
			shift

		elif test "$ARG" == "--distribution"
		then
			LATENCY_DISTRIBUTION=$ARG_NEXT
			shift

		elif test "$ARG" == "--correlation"
		then
			LATENCY_CORRELATION=$ARG_NEXT
			shift

		elif test "$ARG" == "--loss"
		then
			LOSS=$ARG_NEXT
			shift

		elif test "$ARG" == "--loss-correlation"
		then
			LOSS_CORRELATION=$ARG_NEXT
			shift

		elif test "$ARG" == "--time"
		then
			TIME=$ARG_NEXT
			shift

		else
			echo "! Unknown argument: $ARG"
			print_syntax

		fi

	done

} # End of parse_args()


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

if test ! "$1"
then
	print_syntax
fi

parse_args $@

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
echo "# Packet Loss Correlation: ${LOSS_CORRELATION}%"
echo "# Time: ${TIME} seconds"
echo "# "
echo "# Command: ${CMD}"
echo "# "

$CMD
echo "# Network settings applied!  Now sleeping for ${TIME} seconds..."
sleep $TIME

init

echo "# Done!"


