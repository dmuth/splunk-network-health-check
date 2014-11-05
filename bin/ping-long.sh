#!/bin/bash
#
# Ping a specified host.
# The results will be reported to (and stored in) Splunk.
#

TARGET="google.com"

NUM_PINGS=300
#NUM_PINGS=30 # Debugging
#NUM_PINGS=10 # Debugging

ping -c ${NUM_PINGS} -q ${TARGET}



