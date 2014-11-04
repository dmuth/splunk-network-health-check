#!/bin/bash
#
# "Deploy" this app by creating a symlink from $SPLUNK_HOME/etc/apps/Network-Monitor
#

#
# Errors are fatal
#
set -e 

DIR=`pwd`

pushd /opt/splunk/etc/apps > /dev/null
ln -s $DIR Network-Monitor


