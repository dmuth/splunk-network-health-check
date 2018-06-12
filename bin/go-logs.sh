#!/bin/bash

# Errors are fatal
set -e

echo "# "
echo "# Attempting to tail logs from the splunk container"
echo "# "
echo "# Press ^C to exit..."
echo "# "

docker logs -f splunk


