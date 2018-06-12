#!/bin/bash

# Errors are fatal
set -e

docker kill splunk || true
docker rm splunk


