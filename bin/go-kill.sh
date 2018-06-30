#!/bin/bash

# Errors are fatal
set -e

docker kill splunk-network-health-check || true
docker rm splunk-network-health-check


