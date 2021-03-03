#!/bin/bash
#
# Clean up after runnning an instance of Splunk Lab
#

# Errors are fatal
set -e

CLEAN_DATA=""

DATA_DIR="splunk-data"

#
# Change to the parent directory of this script
#
pushd $(dirname $0) > /dev/null
cd ..

#
# Parse our args
#
if test "$1" == "data"
then
	CLEAN_DATA=1

elif test "$1" == "all"
then
	CLEAN_DATA=1
	CLEAN_LOGS=1

else
	echo "! "
	echo "! Syntax: $0 data"
	echo "! "
	exit 1
fi


if test "$CLEAN_DATA"
then
	echo "# "
	echo "# Removing ${DATA_DIR}/ directory..."
	echo "# "
	
	rm -rf ${DATA_DIR}

fi


echo "# Done!"

