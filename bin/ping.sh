#!/bin/bash
#
# Ping a specified host.
# The results will be reported to (and stored in) Splunk.
#

TARGET="google.com"


#NUM_PINGS=3 # Debugging
NUM_PINGS=10

ping -c ${NUM_PINGS} -q ${TARGET}



