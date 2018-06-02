#!/bin/bash
#
# Ping a specified host.
# The results will be reported to (and stored in) Splunk.
#


TARGETS="google.com 1.1.1.1 8.8.8.8"
#TARGETS="${TARGETS} 10.0.0.2" # Debugging

#
# How many pings to me?
#
NUM=10

#
# Summary is written on stderr, so send that to stdout
#
fping -q -c ${NUM} ${TARGETS} 2>&1


