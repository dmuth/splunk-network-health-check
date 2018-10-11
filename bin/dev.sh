#!/bin/bash

# Errors are fatal
set -e

#
# Default targets include Google, their DNS resolver, and CloudFlare's DNS resolver.
#
TARGETS="google.com 8.8.8.8 1.1.1.1"

#
# Our Splunk port on the host.  Defaults to 8000 but can be something else.
#
SPLUNK_PORT=${SPLUNK_PORT:=8000}

if test "$1" == "-h" -o "$1" == "--help"
then
	echo "! "
	echo "! Syntax: $0 [ host [ host [ ... ] ] ]"
	echo "! "
	echo "! host - Specify a host to monitor in addition to the defaults"
	echo "! "
	exit 1
fi

#
# If a target was specified, add it onto the defaults.
#
if test "$1"
then
	TARGETS="${TARGETS} $@"
fi

#
# Switch to the directory where this script lives and go up a directory
#
pushd $(dirname $0) >/dev/null
cd ..

./bin/build.sh


echo "# "
echo "# Running container..."
echo "# "
echo "# TARGETS=${TARGETS}"
echo "# SPLUNK_PORT=${SPLUNK_PORT}"
echo "# "
echo "# For future reference, if you wanted a bash shell, try running this: "
echo "# "
echo "# 	$0 bash"
echo "# "
docker run --rm --name splunk-network-health-check \
	-e "TARGETS=${TARGETS}" \
	-e TZ=EST5EDT \
	-ti \
	-p $SPLUNK_PORT:8000 \
	-v $(pwd)/splunk-app:/app \
	-v $(pwd)/splunk-data:/data \
	-v $(pwd):/mnt \
	--privileged \
	splunk-network-health-check bash


