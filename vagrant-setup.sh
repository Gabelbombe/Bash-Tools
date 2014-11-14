#!/bin/bash

if hash httpd 2>/dev/null; then
	echo installed
else
	echo nope
fi

exit
mkdir -p "/home/$(whoami)/Vagrant/boxes"
cd "/home/$(whoami)/Vagrant/boxes"

#get trusty64 boxfile
wget http://cloud-images.ubuntu.com/vagrant/trusty/trusty-server-cloudimg-i386-juju-vagrant-disk1.box

