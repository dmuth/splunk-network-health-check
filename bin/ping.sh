#!/bin/bash
#
# Ping a specified host.
# The results will be reported to (and stored in) Splunk.
#

TARGET="google.com"

#WAIT_TIME=3 # Debugging
WAIT_TIME=10

#
# -w/-T specifies how long to wait.
# That way, if we're seeing 100% packet loss, the ping command still exits after the appropriate amount of time.
#
if test ${OSTYPE} == "darwin12"
then
	#
	# We're on OS/X!
	#
	ping -t ${WAIT_TIME} -q ${TARGET}

else
	#
	# Assume Linux
	#
	ping -w ${WAIT_TIME} -q ${TARGET}

fi


