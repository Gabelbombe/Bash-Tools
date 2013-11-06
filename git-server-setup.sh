#!/bin/bash
# Git server setup for DEB systems

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-11-06 @ 13:30:39
# VER : Version 1.2.1

# functions
function BLUE() {
  echo -e '\n\E[37;44m'"\033[1m${1}\033[0m\n"
}

function GREEN() {
  echo -e '\n\E[37;42m'"\033[1m${1}\033[0m\n"
}

clear

# ROOT check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as su" 1>&2
   exit 1
fi

\BLUE "Installing GIT Core"

  # APT/YUM install GIT base
  if hash apt-get 2>/dev/null; then
      apt-get install -y git-core
  elif hash yum 2>/dev/null; then
      yum install -y git
  else
    echo "Installer needs to be either YUM or APT" 1>&2 ; exit 1
  fi

\BLUE "Adding GIT as user"

  [ -d "/home/git" ] || mkdir -p /home/git/data
  useradd                           \
    --create-home                   \
    --skel      /dev/null           \
    --home-dir  /home/git           \
    --shell     /bin/bash           \
    --comment   'Web Archive VCS'   \
  git

  chmod -R 0750 /home/git

\BLUE "Adding authorized_keys file"

  mkdir -p /home/git/.ssh 
  chmod 0700 /home/git/.ssh
  
  touch /home/git/.ssh/authorized_keys
  chmod 0600 /home/git/.ssh/authorized_keys

  ssh-keygen -f ~/.ssh/git.dsa -t dsa -N ''

  # create a root key
  cat ~/.ssh/git.dsa.pub >> /home/git/.ssh/authorized_keys

echo -e "Done!" 

\BLUE "Making Repository DIR"
  
  mkdir -p /home/git/web-archive

echo -e "Done!" 

\BLUE "Creating Test Repository"

  mkdir -p /home/git/web-archive/test.git 

  cd /home/git/web-archive/test.git

  git --bare init # create a base repository

\BLUE "Creating Interactive GIT-Shell"

  mkdir -p /home/git/git-shell-commands

  # /home/git/git-shell-commands should exist and have read and execute access.
  git clone https://github.com/ehime/git-commands.git /home/git/git-shell-commands

\BLUE "Locking GIT user"

  chown -R git:git ~git

# Prevent full login for security reasons
  chsh -s /usr/bin/git-shell git

echo -e "Locked."

\GREEN "Finished....."

  exit
