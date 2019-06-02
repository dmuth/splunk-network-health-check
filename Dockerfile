
#
# Build stage
#
# This will build our hacked version of ping, which will then be copied by the main container.
#
FROM debian:stretch as builder

RUN apt-get update && apt-get install -y git gcc make libcap-dev libidn2-0-dev nettle-dev 

#
# Compile my hacked version of ping from https://github.com/dmuth/iputils
# This will give us periodic updates on packets sent/received and include the
# name of the target in the output.
#
WORKDIR /
RUN git clone https://github.com/dmuth/iputils.git
WORKDIR /iputils
RUN make


#
# Base this on the Splunk Lab container
#
FROM dmuth1/splunk-lab

#
# Copy our hacked ping.
#
COPY --from=builder /iputils/ping /iputils/ping

#
# Copy our entrypoint script in, the main thing it will
# do is add to inputs.conf for each target.
#
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#
# Copy in our application
#
COPY splunk-app/ /opt/splunk/etc/apps/Network-Monitor

#
# Expose Splunk web
#
EXPOSE 8000/tcp

ENTRYPOINT ["/entrypoint.sh"]


