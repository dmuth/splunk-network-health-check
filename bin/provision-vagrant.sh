#!/bin/bash
#
# This script is used to provision a Vagrant instance when set up.
#

#
# Errors are fatal
#
set -e

#
# Restart syslog so that it gets the name hostname
#
service rsyslog restart


#
# Install the Splunk package
#
PKG="/vagrant/splunk.deb"
if test -f $PKG
then

	if test ! -f /opt/splunk/bin/splunk
	then
		dpkg -i ${PKG}
	fi

else
	echo "#"
	echo "# Missing file '${PKG}'!"
	echo "#"
	echo "# Need a copy of Splunk Enterprise? A free copy can be downloaded "
	echo "# from http://www.splunk.com/download"
	echo "#"
	exit 1

fi


#
# Set up a symlink for /var/splunk/, which I've also seen used.
#
if test ! -d /var/splunk
then
	pushd /var > /dev/null
	ln -s /opt/splunk
fi


