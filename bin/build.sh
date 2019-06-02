#!/bin/bash

# Errors are fatal
set -e

TARGET=""

function print_syntax() {
	echo "# "
	echo "# Syntax: $0 [ dockerfile_stage ]"
	echo "# "
	exit 1
}

if test "$1" == "-h" -o "$1" == "--help"
then
	print_syntax
fi

if test "$1"
then
	TARGET="--target $1"
fi


#
# Switch to the directory where this script lives and go up a directory
#
pushd $(dirname $0) >/dev/null
cd ..

echo "# "
echo "# Building container..."
echo "# "
docker build ${TARGET} -t splunk-network-health-check .
docker tag splunk-network-health-check dmuth1/splunk-network-health-check 


