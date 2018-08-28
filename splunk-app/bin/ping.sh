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
# Use stdbuf to turn off the buffering so results make it into Splunk immediately
#
stdbuf -oL -eL /iputils/ping ${TARGET} 2>&1 


