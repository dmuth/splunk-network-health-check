# Splunk Network Health Check

This app will monitor health of your Internet connection by pinging Google 
(and a few other hosts) and creating nice graphs.


## Quickest Installation

`curl -s https://raw.githubusercontent.com/dmuth/splunk-network-health-check/master/bin/run.sh | bash`


## Less Quick Installation

Maybe you don't want to pipe some random script on the Internet into your shell, that's cool.
Here are the Docker commands to run it and view the output:

```
docker run --name splunk-network-health-check -d --rm -p 8000:8000 \
	-v $(pwd)/splunk-data:/opt/splunk/var/lib/splunk/defaultdb \
	dmuth1/splunk-network-health-check
docker logs -f splunk-network-health-check
```


No matter how you install it, you can then go to http://localhost:8000/ and get graphs like these:

<img src="./img/network-report.png" width="500" /> 


Data will be persisted in the `splunk-data/` directory between container runs.


### Default Targets

These are the default targets, but can be overridden with `-e TARGETS=...`: 

- google.com
- 8.8.8.8 (Google's DNS Resolver)
- 1.1.1.1 (CloudFlare's DNS Resolver)

I picked Google because it's a fairly well connceted site, and I picked the second two IPs so that if 
DNS is flaky, it won't impact either those, and those two IP addresses are owned by completely different entities.


## More detailed options

- `--restart unless-stopped` - Causes this container to restart if killed Docker is restarted. **This is highly recommended.**
- `-e "TARGETS=google.com cnn.com 8.8.8.8 1.1.1.1"` - Specify hosts to ping
- `-e TZ=EST5EDT` - Specify the timezone of the container (UTC by default)
- `-e SPLUNK_PASSWORD=password` - Set a non-default password. You WILL do this if you run this in a production environment.


## What's Splunk?

Splunk is an amazing app that lets you monitor your logfiles and perform analytics on them.  You can monitor other kinds of data, such as the output of the ping command, which is what this app does.  A free copy of Splunk Enterprise [can be downloaded at Splunk.com](http://www.splunk.com/) and is downloaded in the Dockerfile.


## How does it work?

At its core, this app uses a script called `ping.sh`.  This script runs <a href="https://github.com/dmuth/iputils">a hacked veriosn of ping</a> to ping all targets and report on status (packets sent/packets received) every 10 seconds.


## Security Concerns

**Please** set a password if you are deploying this on anything other than a personal device.
That is done with `-e SPLUNK_PASSWORD=<password>`.


## Uptime Notes

Uptime was a tricky metric to figure out.  There were a few reasons for this:

- `fillnull` mostly worked, but would frequently cause the most recent event to falsely have a packet "loss" of 100%
- If the Internet connection goes down, DNS lookups won't work.
- I observed instances when even pinging IP addresses, `fping` defied its documentation and took 30 seconds to run 10 pings. This meant I could not expect an average of 1 response (or lack thereof) per second.

The math I ended up settling on was taking the average of all "packet loss percent" points from the Packet Loss graph, and subtracting that number from 100.  It's not perfect, but it's the best I can do currently.


## Development


### The Easy Way

There are some helper scripts in `bin/` which make the process less painful:

- `bin/attach.sh` - Spin up a bash shell in a running instance
- `bin/dev.sh [ target [ target [ ... ] ] ] ` - Build an image from the Dockerfile, start it up, and run an interactive `bash` shell. 
   - Any targets that are specified are pinged in addition to the defaults
   - When exited, the container will end.
   - Network data will persist in `splunk-data/` off the project root.
   - Set the `SPLUNK_PORT` environment variable to listen on a port other than 8000 on the Docker host
- `bin/kill.sh` - Stop the container and kill it.
- `bin/logs.sh` - Tail the logs of the currently running container
- `bin/push.sh` - Push the image up to Docker Hub
- `bin/run.sh [ target [ target [ ... ] ] ]` - Pull the laetst copy of the image and create a container named `splunk-network-health-check`.
   - Any targets that are specified are pinged in addition to the defaults
   - Network data will persist in `splunk-data/` off the project root.
   - This container will be started with `--restart unless-stopped`, so if Docker is restarted, so will this container.
   - Set the `SPLUNK_PORT` environment variable to listen on a port other than 8000 on the Docker host


### The Medium Way (with Docker Compose)

- `docker-compose build`
- `docker-compose up -d`
- You can view progress with `docker-compose logs`


### The Hard Way

Here's how to do development:

```
docker build . -t splunk-network-health-check && \
	docker run --rm --name splunk-network-health-check \
	-e TZ=EST5EDT -ti -p 8000:8000 \
	-v $(pwd)/splunk-data:/opt/splunk/var/lib/splunk/defaultdb \
	-v $(pwd):/mnt \
	--privileged \
	splunk-network-health-check
docker tag splunk-network-health-check dmuth1/splunk-network-health-check
docker push dmuth1/splunk-network-health-check
```

`--privileged` is specified so that `/opt/splunk/etc/apps/Network-Monitor/bin/icmp_loop.sh` can
be run inside of the container for testing.


## Known Bugs

For reasons unclear to me, if you set up a VPN connection, this completely breaks ping in all
Docker containers.  Even `docker run alpine ping google.com` doesn't work.

The workaround is to simply restart Docker.  If you started your container with `--restart unless-stopped`,
it will start up automatically.  I am unclear on if this is something that can be fixed.


## Questions, comments, abuse, and offers of employment

- Email: doug.muth@gmail.com
- Twitter: http://twitter.com/dmuth
- Facebook: http://facebook.com/dmuth


