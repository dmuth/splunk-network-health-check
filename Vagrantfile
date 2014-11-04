# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Sample command line for bringing up an instance and configuring it:
#
# vagrant destroy -f main && vagrant up main && ./go.sh -i ./inventory/vagrant -l vagrant-btsync-main
#

Vagrant.configure("2") do |config|

	#
	# Cache anything we download with apt-get
	#
	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.scope = :box
	end

	#
	# This is our main host.  It also runs a Splunk indexer and search head.
	#
	config.vm.define :main do |host|

		host.vm.box = "precise64"
		host.vm.box_url = "http://files.vagrantup.com/precise64.box"
		host.vm.hostname = "main"
		host.vm.network "private_network", ip: "10.0.10.101"

		#
 		# Splunk HTTP/HTTPS
		#
		host.vm.network :forwarded_port, guest: 8000, host: 8000

		#
		# Set the amount of RAM and CPU cores
		#
		host.vm.provider "virtualbox" do |v|
			v.memory = 512
			v.cpus = 2
		end

		#
		# Updating the plugins at start time never ends well.
		#
		if Vagrant.has_plugin?("vagrant-vbguest")
			config.vbguest.auto_update = false
		end

		#
		# Provision this instance
		#
		host.vm.provision "shell", path: "provision-vagrant.sh"

	end


end


