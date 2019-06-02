#!/bin/bash
#
# This is script to start Splunk
#

#
# Errors are fatal
# 
set -e

SPLUNK_PASSWORD="${SPLUNK_PASSWORD:-password}"
TARGETS="${TARGETS:-google.com 8.8.8.8 1.1.1.1}"


#
# Require the user to accept the license to continue
#
if test "$SPLUNK_START_ARGS" != "--accept-license"
then
	echo "! "
	echo "! You need to accept the Splunk License in order to continue."
	echo "! Please restart this container with SPLUNK_START_ARGS set to \"--accept-license\" "
	echo "! as follows: "
	echo "! "
	echo "! SPLUNK_START_ARGS=--accept-license"
	echo "! "
	exit 1
fi

#
# Check for bad passwords.
#
if test "$SPLUNK_PASSWORD" == "password"
then
	echo "! "
	echo "! "
	echo "! Cowardly refusing to set the password to 'password'. Please set a different password."
	echo "! "
	echo "! If you need help picking a secure password, there's an app for that:"
	echo "! "
	echo "!	https://diceware.dmuth.org/"
	echo "! "
	echo "! "
	exit 1

elif test "$SPLUNK_PASSWORD" == "12345"
then
	echo "! "
	echo "! "
	echo "! This is not Planet Spaceball.  Please don't use 12345 as a password."
	echo "! "
	echo "! "
	exit 1

fi


PASSWORD_LEN=${#SPLUNK_PASSWORD}
if test $PASSWORD_LEN -lt 8
then
	echo "! "
	echo "! "
	echo "! Admin password needs to be at least 8 characters!"
	echo "! "
	echo "! Password specified: ${SPLUNK_PASSWORD}"
	echo "! "
	echo "! "
	exit 1
fi


#
# Set our default password
#
pushd /opt/splunk/etc/system/local/ >/dev/null

cat user-seed.conf.in | sed -e "s/%password%/${SPLUNK_PASSWORD}/" > user-seed.conf
cp web.conf.in web.conf

popd > /dev/null


#
# Create inputs.conf with our targets
#
pushd /opt/splunk/etc/apps/Network-Monitor/default >/dev/null

# Remove a previously existing version of this file
rm -f inputs.conf

for TARGET in $(echo ${TARGETS} | tr "," " ")
do
	echo "# Adding target '${TARGET}' to inputs.conf..."
	cat inputs.conf.in | sed -e "s/%target%/${TARGET}/" >> inputs.conf
done

popd > /dev/null


#
# If we're running in devel mode, link local to default so that any
# changes we make to the app in Splunk go straight into default and
# I don't have to move them by hand.
#
if test "$SPLUNK_DEVEL"
then
	pushd /opt/splunk/etc/apps/Network-Monitor >/dev/null
	if test ! -e local
	then
		echo "# "
		echo "# Creating symlink to local/ in devel mode..."
		echo "# "
		ln -sfv default local
	fi
	popd > /dev/null
fi

#
# Start Splunk
#
/opt/splunk/bin/splunk start --accept-license

echo "# "
echo "# If your data is not persisted, be sure you ran this container with: "
echo "# "
echo "#		-v \$(pwd)/splunk-data:/opt/splunk/var/lib/splunk/defaultdb"
echo "# "
echo "# "

if test ! "$@"
then
	echo "# "
	echo "# If you were looking to run this container interactively, please restart"
	echo "# this container with the 'bash' argument."
	echo "# "
	echo "# Press ^C when you want to exit this container..."
	echo "# "
	tail -f /opt/splunk/var/log/splunk/splunkd_stderr.log

else
	echo "# "
	echo "# Running command '$@' in the container..."
	echo "# "
	exec $@

fi


