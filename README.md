# Splunk Network Monitor


A Splunk app to monitor your Internet connection


**tl;dr** Keep track of your Internet connection and get pretty graphs like these:

![Short Term Network Report](./img/short-term-network-report.png) ![Long Term Network Report](./img/long-term-network-report.png)


## What's Splunk?

Splunk is an amazing app that lets you monitor your logfiles and perform analytics on them.  You can monitor other kinds of data, such as the output of the ping command, which is what this app does.  A free copy of Splunk Enterprise [can be downloaded at Splunk.com](http://www.splunk.com/)


## Installation

- Download this app:
	- `git clone git@github.com:dmuth/splunk-network-monitor.git`
- Deploy this app:
	- `./bin/deploy_symlink.sh $SPLUNK_ROOT` if you'd like to have a symlink pointing to this directory
	- `./bin/deploy.sh $SPLUNK_ROOT` if you'd like to have this directory copied into $SPLUNK_HOME/Network-Monitor/
- Restart Splunk:
    - `$SPLUNK_HOME/bin/splunk restart`


## Usage

While in Splunk, click "App" and then "Network Monitor".

There will be a menu across the top that lets you run reports.


## How does it work?

At its core, this app uses not one, but **two** scripts to run ping.  The first script (ping.sh) pings google.com for 10 seconds at a time and then returns the results.  The second script (ping-long.sh) pings google.com for 5 minutes at a time and then returns the results.  The reason for these two separate scripts is because the first script is useful seeing what short-term behavior of your Internet connection is, but there can be a pause of as much as 1 second between invocations of the script.  ping-long.sh mitigates that by running for a much longer interval and can be used to see how your connection performed over a longer period of time.


### Why ping google.com?

Google's website is ridiculuously multi-homed, and as such has excellent availability.

In the future I'll look into adding a configuration page so that the host to ping can be specified.  (This is my first Splunk app, so one thing at a time :-)  )



## Compatibility

This has been written for (and tested on) Splunk 6.2




## Questions, comments, abuse, and offers of employment

Hit me up via email at dmuth@dmuth.org.
