#!/bin/bash
#
# "Deploy" this app by creating a symlink from $SPLUNK_HOME/etc/apps/Network-Monitor
#

#
# Errors are fatal
#
set -e 

#
# Change into the parent directory of this script
#
cd `dirname $0`
cd ..
DIR=`pwd`

#
# Now make a symlink under the apps directory to this directory
#
pushd /opt/splunk/etc/apps > /dev/null
ln -s $DIR Network-Monitor


