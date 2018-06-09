#!/bin/bash

# Errors are fatal
set -e

#
# Switch to the directory where this script lives and go up a directory
#
pushd $(dirname $0) >/dev/null
cd ..

docker build . -t splunk && \
	docker run --rm --name splunk \
	-e INTERACTIVE=1 -e TZ=EST5EDT -ti -p 8000:8000 \
	-v $(pwd)/splunk-network-monitor-data:/opt/splunk/var/lib/splunk/defaultdb \
	-v $(pwd):/mnt \
	--privileged \
	splunk


