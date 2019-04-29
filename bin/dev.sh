#!/bin/bash

# Errors are fatal
set -e


#
# Change to the parent of this script
#
pushd $(dirname $0) > /dev/null
cd ..

./bin/build.sh

echo "# "
echo "# Tagging container..."
echo "# "
docker tag splunk-network-health-check dmuth1/splunk-network-health-check

SPLUNK_DEVEL=1 SPLUNK_BG=0 SPLUNK_PASSWORD=${SPLUNK_PASSWORD:-password1} ./go.sh

