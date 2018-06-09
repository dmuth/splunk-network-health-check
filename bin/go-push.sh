#!/bin/bash

# Errors are fatal
set -e

docker tag splunk dmuth1/splunk-network-monitor
docker push dmuth1/splunk-network-monitor

