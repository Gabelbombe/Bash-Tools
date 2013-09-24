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

echo -e "\nInstalling GIT Core\n\n"

  apt-get install -y git-core

echo -e "\nAdding GIT as user\n"

  sudo useradd -m -d /home/git -s /bin/sh -c 'Git' git

echo -e "\nAdding dummy authorized_keys file\n"

  su git -c 'mkdir -p ~git/.ssh && chmod 0700 ~git/.ssh'
  su git -c 'touch ~git/.ssh/authorized_keys && chmod 0600 ~git/.ssh/authorized_keys'

# don't need authkeys yet
#  for x in `ls $DIR/*.pub`; do 
#    su git -c 'cat "$x" >> ~/authorized_keys'
#  done

echo -e "\nMaking Repository DIR\n\n"
  
  su git -c 'mkdir -p ~git/Repositories'

echo -e "\nLocking GIT user\n\n"

# Prevent full login for security reasons
  chsh -s /usr/bin/git-shell git

echo -e "\nFinished.....\n\n"

  exit