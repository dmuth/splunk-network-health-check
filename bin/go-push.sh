#!/bin/bash

# Errors are fatal
set -e

docker tag splunk dmuth1/splunk-network-health-check
docker push dmuth1/splunk-network-health-check

