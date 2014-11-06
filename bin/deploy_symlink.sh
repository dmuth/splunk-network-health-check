#!/bin/bash
#
# "Deploy" this app by creating a symlink from $SPLUNK_HOME/etc/apps/Network-Monitor
#

#set -x # Debugging

#
# Errors are fatal
#
set -e 


if test ! "$1"
then
	echo "Syntax: $0 \$SPLUNK_ROOT"
	exit 1
fi

SPLUNK_ROOT=$1
TARGET=${SPLUNK_ROOT}/etc/apps

#
# Change into the parent directory of this script
#
cd `dirname $0`
cd ..
DIR=`pwd`

#
# Now make a symlink under the apps directory to this directory
#
pushd $TARGET > /dev/null
ln -sf $DIR Network-Monitor

echo "# "
echo "# Created a symlink to the application from ${TARGET}"
echo "# "

