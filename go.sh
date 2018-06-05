#!/bin/bash

# Errors are fatal
set -e

#
# Switch to the directory where this script lives
#
pushd $(dirname $0) >/dev/null


echo "# "
echo "# Starting Network Monitor in the background"
echo "# "


docker pull dmuth1/splunk-network-monitor:latest
docker run --name splunk -d --rm -p 8000:8000 \
	-v $(pwd)/splunk-network-monitor-data:/opt/splunk/var/lib/splunk/defaultdb \
	dmuth1/splunk-network-monitor


echo "# "
echo "# Network Monitor Started! "
echo "# "
echo "# Go to http://localhost:8000/ to view graphs"
echo "# "

