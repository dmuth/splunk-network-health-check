#!/bin/bash
#
# Ping a specified host.
# The results will be reported to (and stored in) Splunk.
#

# Errors are fatal
set -e

if test ! "$1"
then
	echo "! "
	echo "! Syntax: $0 host"
	echo "! "
	exit 1
fi

TARGET=$1
#
# Go for 601 seconds so that, under normal network conditions, the line 
# with the target, transmitted, and received values will be printed.
# If it's just 600, then we get a "gap" every 10 minutes.
#
NUM=601

#
# Ping for a time period and then stop.
# The reason we do this is that certain IPs (such as Google) may change frequently.
# This is doubly so if you are attached to a hotspot that is moving (Amtrak!).
#
while true
do

	#
	# Use stdbuf to turn off the buffering so results make it into Splunk immediately
	#
	stdbuf -oL -eL /iputils/ping -c ${NUM} ${TARGET} 2>&1 

done


