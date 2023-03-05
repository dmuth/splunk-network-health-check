#!/bin/bash

# Errors are fatal
set -e

echo "# Killing Splunk Lab container..."
docker kill splunk-network-health-check || true
docker rm splunk-network-health-check || true
echo "# Done!"

