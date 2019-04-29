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
SPLUNK_PASSWORD=${SPLUNK_PASSWORD:-password}
SPLUNK_DATA=${SPLUNK_DATA:-splunk-data}
SPLUNK_PORT=${SPLUNK_PORT:-8000}
SPLUNK_BG=${SPLUNK_BG:-1}
SPLUNK_DEVEL=${SPLUNK_DEVEL:-}
DOCKER_NAME=${DOCKER_NAME:-splunk-network-health-check}
DOCKER_RM=${DOCKER_RM:--1}
DOCKER_CMD=${DOCKER_CMD:-}


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


if test "$SPLUNK_DEVEL"
then
	#
	# This wacky check for $SPLUNK_BG is here because setting it
	# an empty string causes it to "default" to 1.  Silly bash!
	#
	if test "$SPLUNK_BG" -a "$SPLUNK_BG" != 0
	then
		echo "! "
		echo "! You cannot specify both SPLUNK_DEVEL and SPLUNK_BG!"
		echo "! "
		exit 1
	fi
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
# Start forming our command
#
CMD="docker run \
	--privileged \
	-p ${SPLUNK_PORT}:8000 \
	-e TARGETS=${TARGETS} \
	-e SPLUNK_PASSWORD=${SPLUNK_PASSWORD} \
	-v $(pwd)/${SPLUNK_DATA}:/data 
	"

if test "${DOCKER_NAME}"
then
	CMD="${CMD} --name ${DOCKER_NAME}"
fi

#
# DOCKER_RM defaults to -1 so that it can be overridden.
# Kinda silly, but that's how bash works.  
# (But maybe there is a better way? Someone send me a PR!)
#
if test "${DOCKER_RM}" == "-1" -o "${DOCKER_RM}" == 0
then
	DOCKER_RM=""
fi

if test "${DOCKER_RM}"
then
	CMD="${CMD} --rm"
fi

if test "$SPLUNK_BG" -a "$SPLUNK_BG" != 0
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
fi

if test "$DOCKER_CMD"
then
	CMD="${CMD} ${DOCKER_CMD} "
fi


IMAGE="dmuth1/splunk-network-health-check"
#IMAGE="splunk-network-health-check" # Debugging/testing

CMD="${CMD} ${IMAGE}"

if test "$SPLUNK_DEVEL"
then
	CMD="${CMD} bash"
fi

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
echo "# Indexed data will be stored in:    ${SPLUNK_DATA} (Change with \$SPLUNK_DATA)"
if test "$DOCKER_NAME"
then
	echo "# Docker container name:             ${DOCKER_NAME}"
else
	echo "# Docker container name:             (Set with \$DOCKER_NAME, if you like)"
fi

if test "$DOCKER_RM"
then
	echo "# Removing container at exit?        YES"
else
	echo "# Removing container at exit?        NO (Set with \$DOCKER_RM=1)"
fi

if test "$DOCKER_CMD"
then
	echo "# Docker command injection:          ${DOCKER_CMD}"
else
	echo "# Docker command injection:          (Feel free to set with \$DOCKER_CMD)"
fi

echo "# "
if test "$SPLUNK_BG" -a "$SPLUNK_BG" != 0
then
echo "# Background Mode?                   YES"
else 
echo "# Background Mode?                   NO (Set with \$SPLUNK_BG)"
fi

echo "# "

echo "> "
echo "> Press ENTER to run Splunk Health Check with the above settings, or ctrl-C to abort..."
echo "> "
read

echo "# "
echo "# Launching container..."
echo "# "

if test ! "$SPLUNK_BG" -o "$SPLUNK_BG" == 0
then
	$CMD

else
	if test ! "$DOCKER_NAME"
	then
		ID=$($CMD)
		SHORT_ID=$(echo $ID | cut -c-4)

	else
		ID=$($CMD)
		SHORT_ID=$DOCKER_NAME

	fi
	echo "#"
	echo "# Running Docker container with ID: ${ID}"
	echo "#"
	echo "# Inspect container logs with: docker logs ${SHORT_ID}"
	echo "#"
	echo "# Kill container with: docker kill ${SHORT_ID}"
	echo "#"

fi


