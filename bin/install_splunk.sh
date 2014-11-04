#!/bin/bash
#
# This script is used to start Splunk and enable to be started at boot time
#
# Note that you must SSH into your instance to run this command.
#


set -e # Errors are fatal
#set -x # Debugging

if test $UID != 0
then
	echo "***"
	echo "*** You must run this script as root!"
	echo "***"
	exit 1
fi

echo "# "
echo "# "
echo "# Starting Splunk for the first time. "
echo "# NOTE: You MUST agree to the license terms to continue."
echo "# "
echo "# "
sleep 3
/opt/splunk/bin/splunk start

echo "# "
echo "# Setting Splunk to start on system boot."
echo "# "
/opt/splunk/bin/splunk enable boot-start
echo "# "
echo "# Done!"
echo "# "


