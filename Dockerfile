#
# Based on https://github.com/splunk/docker-splunk/blob/master/enterprise/Dockerfile
#
# I slimmed this down, as I have no desire to run as a separate user, set up a Deployment
# Server, generate PDFs, etc.  All I want to do is run a this single app.
#
FROM debian:jessie

ENV SPLUNK_PRODUCT splunk
ENV SPLUNK_VERSION 7.1.1
ENV SPLUNK_BUILD 8f0ead9ec3db
ENV SPLUNK_FILENAME splunk-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz

ENV SPLUNK_HOME /opt/splunk


ARG DEBIAN_FRONTEND=noninteractive

# make the "en_US.UTF-8" locale so splunk will be utf-8 enabled by default
RUN apt-get update  && apt-get install -y --no-install-recommends apt-utils && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Download official Splunk release, verify checksum and unzip in /opt/splunk
# Also backup etc folder, so it will be later copied to the linked volume
RUN apt-get update && apt-get install -y wget sudo \
    && mkdir -p ${SPLUNK_HOME} \
    && wget -qO /tmp/${SPLUNK_FILENAME} https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME} \
    && wget -qO /tmp/${SPLUNK_FILENAME}.md5 https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME}.md5 \
    && (cd /tmp && md5sum -c ${SPLUNK_FILENAME}.md5) \
    && tar xzf /tmp/${SPLUNK_FILENAME} --strip 1 -C ${SPLUNK_HOME} \
    && rm /tmp/${SPLUNK_FILENAME} \
    && rm /tmp/${SPLUNK_FILENAME}.md5 \
    && apt-get purge -y --auto-remove wget 
    #&& rm -rf /var/lib/apt/lists/*

#
# Copy in some Splunk configuration
#
COPY files/user-seed.conf /opt/splunk/etc/system/local/
COPY files/web.conf /opt/splunk/etc/system/local
COPY files/splunk-launch.conf /opt/splunk/etc/

#
# Copy in the app
# 
COPY Network-Monitor/ /opt/splunk/etc/apps/Network-Monitor/

#
# Copy in our entry script which will install Splunk
#
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#
# Expose Splunk web
#
EXPOSE 8000/tcp

#
# Folder for our data
#
VOLUME [ "/opt/splunk/var/lib/splunk/defaultdb" ]

CMD ["/entrypoint.sh"]


