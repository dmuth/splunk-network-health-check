#!/bin/bash
#
# This script is used to provision a Vagrant instance when set up.
#

#
# Errors are fatal
#
set -e

#
# Restart syslog so that it gets the hostname
#
FILE="/var/local/vagrant-syslog"
if test ! -f $FILE
then
	echo "# "
	echo "# Restarting syslog to get the correct hostname..."
	echo "# "
	service rsyslog restart
fi
touch $FILE


#
# Install the Splunk package
#
PKG="/vagrant/splunk.deb"
if test -f $PKG
then

	if test ! -f /opt/splunk/bin/splunk
	then
		echo "# "
		echo "# Installing Splunk!"
		echo "# "
		dpkg -i ${PKG}

		echo "# "
		echo "# Starting Splunk..."
		echo "# "
		/opt/splunk/bin/splunk start --accept-license

	fi

else
	echo "!"
	echo "! Missing file '${PKG}'!"
	echo "!"
	echo "! Need a copy of Splunk Enterprise? A free copy can be downloaded "
	echo "! from http://www.splunk.com/download"
	echo "!"
	exit 1

fi


#
# Set up a symlink for /var/splunk/, which I've also seen used.
#
if test ! -d /var/splunk
then
	echo "# "
	echo "# Creating symlink for Splunk in /var/splunk/..."
	echo "# "
	cd /var > /dev/null
	ln -s /opt/splunk
fi


if test ! -d "/var/splunk/etc/apps/network-monitor"
then
	echo "# "
	echo "# Now installing Splunk network monitor and restarting Splunk..."
	echo "# "
	cd /var/splunk/etc/apps/
	ln -s /vagrant network-monitor
	/var/splunk/bin/splunk restart
fi

echo "# "
echo "# To connect to Splunk: "
echo "# "
echo "# http://localhost:8000/ "
echo "# "
echo "# To view the Network Monitor: "
echo "# "
echo "# http://localhost:8000/en-US/app/network-monitor/"
echo "# "



