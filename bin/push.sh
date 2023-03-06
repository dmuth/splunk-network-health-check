#!/bin/bash

# Errors are fatal
set -e

# Load our variables
. ./bin/lib.sh

docker push dmuth1/splunk-network-health-check
docker push dmuth1/splunk-network-health-check:latest
docker push dmuth1/splunk-network-health-check:${SPLUNK_VERSION_MAJOR}
docker push dmuth1/splunk-network-health-check:${SPLUNK_VERSION}

