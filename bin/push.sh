#!/bin/bash

# Errors are fatal
set -e

docker tag splunk-network-health-check dmuth1/splunk-network-health-check
docker push dmuth1/splunk-network-health-check

