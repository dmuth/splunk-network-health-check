#!/bin/bash

# Errors are fatal
set -e

#
# Switch to the directory where this script lives and go up a directory
#
pushd $(dirname $0) >/dev/null
cd ..

echo "# "
echo "# Building container..."
echo "# "
docker build . -t splunk-network-health-check 


