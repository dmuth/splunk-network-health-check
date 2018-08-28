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
# Set our default password
#
pushd /opt/splunk/etc/system/local/ >/dev/null

cat user-seed.conf.in | sed -e "s/%password%/${SPLUNK_PASSWORD}/" > user-seed.conf
cat web.conf.in | sed -e "s/%password%/${SPLUNK_PASSWORD}/" > web.conf

popd > /dev/null


#
# Create inputs.conf with our targets
#
pushd /opt/splunk/etc/apps/Network-Monitor/default >/dev/null

for TARGET in ${TARGETS}
do
	echo "# Adding target '${TARGET}' to inputs.conf..."
	cat inputs.conf.in | sed -e "s/%target%/${TARGET}/" >> inputs.conf
done

popd > /dev/null


#
# Start Splunk
#
/opt/splunk/bin/splunk start --accept-license

echo "# "
echo "# If your data is not persisted, be sure you ran this container with: "
echo "# "
echo "#		-v \$(pwd)/data:/opt/splunk/var/lib/splunk/defaultdb"
echo "# "
echo "# Timezone in UTC?  Specify your timezone with -e, such as:"
echo "# "
echo "# 	-e TZ=EST5EDT"
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


