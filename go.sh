#!/bin/bash
#
# Wrapper script to set up Splunk Helath Check
#
# To test this script out, set up a webserver:
# 
#	python -m SimpleHTTPServer 8000
#
# Then run the script:
#
#	bash <(curl -s localhost:8000/go.sh)
#


# Errors are fatal
set -e


#
# Set default values for our vars
#
TARGETS="${TARGETS:-google.com,8.8.8.8,1.1.1.1}"
SPLUNK_PASSWORD=${SPLUNK_PASSWORD:-password1}
SPLUNK_DATA=${SPLUNK_DATA:-splunk-data}
SPLUNK_PORT=${SPLUNK_PORT:-8000}
SPLUNK_DEVEL=${SPLUNK_DEVEL:-}
ETC_HOSTS=${ETC_HOSTS:-no}
DOCKER_NAME=${DOCKER_NAME:-splunk-network-health-check}
DOCKER_RM=${DOCKER_RM:-1}


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
# Yes, I am aware that the password checking logic is a duplicate of what's in the 
# container's entry point script.  But if someone is running Splunk Health Check through this
# script, I want bad passwords to cause failure as soon as possible, because it's 
# easier to troubleshoot here than through Docker logs.
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


if ! test $(which docker)
then
	echo "! "
	echo "! Docker not found in the system path!"
	echo "! "
	echo "! Please double-check that Docker is installed on your system, otherwise you "
	echo "! can go to https://www.docker.com/ to download Docker. "
	echo "! "
	exit 1
fi


#
# Catch targets with spaces in it (old style)
#
case "$TARGETS" in
	*\ *)
		echo "! "
		echo "! You cannot have strings in the target string: ${TARGETS}"
		echo "! "
		echo "! Instead, try commas between targets.  "
		echo "! 	e.g. TARGETS=google.com,8.8.8.8"
		echo "! "
		echo "! "
		exit 1
		;;
esac


#
# Sanity check
#
if test "$ETC_HOSTS" != "no"
then
	if test ! -f ${ETC_HOSTS}
	then
		echo "! Unable to read file '${ETC_HOSTS}' specfied in \$ETC_HOSTS!"
		exit 1
	fi
fi


#
# Start forming our command
#
CMD="docker run \
	--privileged \
	-p ${SPLUNK_PORT}:8000 \
	-e TARGETS=${TARGETS} \
	-e SPLUNK_PASSWORD=${SPLUNK_PASSWORD} \
	"

#
# If SPLUNK_DATA is no, we're not exporting it. 
# Useful for re-importing everything every time.
#
if test "${SPLUNK_DATA}" != "no"
then
	CMD="$CMD -v $(pwd)/${SPLUNK_DATA}:/data "
fi


if test "${DOCKER_NAME}"
then
	CMD="${CMD} --name ${DOCKER_NAME}"
fi

#
# Only disable --rm if DOCKER_RM is set to "no".
# We want --rm action by default, since we also have a default name
# and don't want name conflicts.
#
if test "$DOCKER_RM" == "no"
then
	DOCKER_RM=""
fi

if test "${DOCKER_RM}"
then
	CMD="${CMD} --rm"
else 
	CMD="${CMD} --restart unless-stopped "
fi

if test "${ETC_HOSTS}" != "no"
then
        CMD="$CMD -v $(pwd)/${ETC_HOSTS}:/etc/hosts.extra "
fi

if test ! "$SPLUNK_DEVEL"
then
	CMD="${CMD} -d "
fi

if test "$SPLUNK_START_ARGS" -a "$SPLUNK_START_ARGS" != 0
then
	CMD="${CMD} -e SPLUNK_START_ARGS=${SPLUNK_START_ARGS}"
fi

if test "$SPLUNK_DEVEL"
then
	CMD="${CMD} -it"
	CMD="${CMD} -v $(pwd):/mnt "

#
# In devel mode, we'll mount the splunk-lab/ directory to the app directory
# here, and the entrypoint.sh script will create the local/ symlink
# (with build.sh removing said symlink before building any images)
#
CMD="${CMD} -v $(pwd)/splunk-app:/opt/splunk/etc/apps/Network-Monitor "
CMD="${CMD} -e SPLUNK_DEVEL=${SPLUNK_DEVEL} "

fi


DOCKER_V="-v $(pwd)/user-prefs.conf:/opt/splunk/etc/users/admin/user-prefs/local/user-prefs.conf"
CMD="${CMD} ${DOCKER_V}"

#
# Create our user-prefs.conf which will be pulled into Splunk at runtime
# to set the default app.
#
cat > user-prefs.conf << EOF
#
# Created by Splunk Network Health Check
#
[general]
default_namespace = Network-Monitor
EOF


IMAGE="dmuth1/splunk-network-health-check"
#IMAGE="splunk-network-health-check" # Debugging/testing

CMD="${CMD} ${IMAGE}"

if test "$SPLUNK_DEVEL"
then
	CMD="${CMD} bash"
fi

echo
echo "    ____        _             _      _   _      _                      _     "
echo "   / ___| _ __ | |_   _ _ __ | | __ | \ | | ___| |___      _____  _ __| | __ "
echo "   \___ \| '_ \| | | | | '_ \| |/ / |  \| |/ _ \ __\ \ /\ / / _ \| '__| |/ / "
echo "    ___) | |_) | | |_| | | | |   <  | |\  |  __/ |_ \ V  V / (_) | |  |   <  "
echo "   |____/| .__/|_|\__,_|_| |_|_|\_\ |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\ "
echo "         |_|                                                                 "
echo "    _   _            _ _   _        ____ _               _                   "
echo "   | | | | ___  __ _| | |_| |__    / ___| |__   ___  ___| | __               "
echo "   | |_| |/ _ \/ _\` | | __| '_ \  | |   | '_ \ / _ \/ __| |/ /               "
echo "   |  _  |  __/ (_| | | |_| | | | | |___| | | |  __/ (__|   <                "
echo "   |_| |_|\___|\__,_|_|\__|_| |_|  \____|_| |_|\___|\___|_|\_\               "
                                                                           
echo


echo "# "
if test ! "${SPLUNK_DEVEL}"
then
	echo "# About to run Splunk Health Check!"
else
	echo "# About to run Splunk Health Check IN DEVELOPMENT MODE!"
fi
echo "# "
echo "# Before we do, please take a few seconds to ensure that your options are correct:"
echo "# "
echo "# URL:                               https://localhost:${SPLUNK_PORT} (Change with \$SPLUNK_PORT)"
echo "# Login/password:                    admin/${SPLUNK_PASSWORD} (Change with \$SPLUNK_PASSWORD)"
echo "# "
echo "# Targets to ping:                   ${TARGETS} (Override with \$TARGETS)" 
echo "# "
if test "${SPLUNK_DATA}" != "no"
then
	echo "# Indexed data will be stored in:    ${SPLUNK_DATA} (Change with \$SPLUNK_DATA, disable with SPLUNK_DATA=no)"
else
	echo "# Indexed data WILL NOT persist.     (Change by setting \$SPLUNK_DATA)"
fi

if test "$DOCKER_NAME"
then
	echo "# Docker container name:             ${DOCKER_NAME}"
else
	echo "# Docker container name:             (Set with \$DOCKER_NAME, if you like)"
fi

if test "$DOCKER_RM"
then
	echo "# Removing container at exit?        YES (Disable with \$DOCKER_RM=no)"
else
	echo "# Removing container at exit?        NO (Set with \$DOCKER_RM=1)"
fi

if test "$ETC_HOSTS" != "no"
then
	echo "# /etc/hosts addition:               ${ETC_HOSTS} (Disable with \$ETC_HOSTS=no)"
else
	echo "# /etc/hosts addition:               NO (Set with \$ETC_HOSTS=filename)"
fi


echo "# "

if test "$SPLUNK_PASSWORD" == "password1"
then
	echo "# "
	echo "# PLEASE NOTE THAT YOU USED THE DEFAULT PASSWORD"
	echo "# "
	echo "# If you are testing this on localhost, you are probably fine."
	echo "# If you are not, then PLEASE use a different password for safety."
	echo "# If you have trouble coming up with a password, I have a utility "
	echo "# at https://diceware.dmuth.org/ which will help you pick a password "
	echo "# that can be remembered."
	echo "# "
fi

echo "> "
echo "> Press ENTER to run Splunk Health Check with the above settings, or ctrl-C to abort..."
echo "> "
read

echo "# "
echo "# Launching container..."
echo "# "

if test "$SPLUNK_DEVEL"
then
	$CMD

elif test ! "$DOCKER_NAME"
then
	ID=$($CMD)
	SHORT_ID=$(echo $ID | cut -c-4)

else
	ID=$($CMD)
	SHORT_ID=$DOCKER_NAME

	echo "#"
	echo "# Running Docker container with ID: ${ID}"
	echo "#"
	echo "# Inspect container logs with: docker logs ${SHORT_ID}"
	echo "#"
	echo "# Kill container with: docker kill ${SHORT_ID}"
	echo "#"

fi


