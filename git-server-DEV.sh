#!/bin/bash

clear

# Init
FILE="/tmp/out.$$"
GREP="/bin/grep"

# ROOT check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as su" 1>&2
   exit 1
fi

echo -e "Checking PERL version\n\n"

  PERL="${perl --version |grep 'This is perl,' |awk '{print $4}'}"

echo $PERL 
exit

echo -e "\nInstalling GIT Core\n\n"

  apt-get install -y git-core

echo -e "\nInstalling GIT\n\n"

	# install GIT base
	yum install -y git

echo -e "\nAdding GIT as user\n"

 sudo adduser \
   --system \
   --shell /bin/sh \
   --gecos 'GIT Version Control System...' \
   --group \
   --disabled-password \
   --home /home/git \
   git

echo -e "\nAdding dummy authorized_keys file\n"

  sudo -u git cd
  sudo -u git mkdir .ssh

# don't need authkeys yet
#  for x in `ls $DIR/*.pub`; do 
#    sudo -u git cat "$x" >> ~/authorized_keys
#  done

echo -e "\nMoving to directory\n\n"

  mkdir ~/