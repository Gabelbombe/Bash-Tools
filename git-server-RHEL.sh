#!/bin/bash

clear

# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"

# ROOT check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo -e "\nAdding RPM resource to RPM list\n\n"

	# RHEL's repo does not have GIT in it, add the RPM for source
	rpm -ivh http://fedora.mirror.nexicom.net/epel/6/i386/epel-release-6-8.noarch.rpm

echo -e "\nInstalling GIT\n\n"

	# install GIT base
	yum install -y git

echo -e "\nAdding GIT as user\n"

	adduser git

echo -e "\nAdding dummy authorized_keys file\n"

  sudo -u git cd
  sudo -u git mkdir .ssh

# don't need authkeys yet
#  for x in `ls $DIR/*.pub`; do 
#    sudo -u git cat "$x" >> ~/authorized_keys
#  done