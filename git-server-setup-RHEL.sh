#!/bin/env bash
# Git server setup for RHEL systems

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-09-26 @ 10:06:43
# VER : Version 1.01

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

	# install GIT base
	yum install -y git

\BLUE "Adding GIT as user"

  [ -d "/srv/data" ] || mkdir -p /srv/data
  useradd                           \
    --create-home                   \
    --skel      /dev/null           \
    --home-dir  /srv/data/git       \
    --shell     /bin/bash           \
    --comment   'Web Archive VCS'   \
  git

  chmod 0750 /srv/data/git

\BLUE "Adding dummy authorized_keys file"

  mkdir -p ~git/.ssh 
  chmod 0700 ~git/.ssh
  
  touch ~git/.ssh/authorized_keys
  chmod 0600 ~git/.ssh/authorized_keys

  # create a test key
  echo 'ssh-dss AAAAB3NzaC1kc3MAAACBAKUSRr2VfLn7LUnhRkwHGpU2eb41wFCBsizmiE9Kg61WitIcsYnBIDy48k/OicmmCsgCO7VKweCSXntnVK43q84g8J81+dlytWQnL80af/mTKsBw+5L1CSDVkbjwYOMPv9VCUcSJ9uawDPMNfEQQia1P2CM+gZPtXex4HD2ay6+7AAAAFQD4eYPJwvsDZraF9EPA6/cplTQ7VwAAAIB/n/eNsYNHn5svEYeXmYnqSuytQBcyvHTYmaW1S9Hc4IT1MFhoeVw77g++r07dKGbrIGTv62phsIHiH3BILWn560AXQ77spq/yO6oKpZpNa94fQjM1cSgNDbvmoCa+8OqxIfy2pz8h7G7K2f3umQvVIrXAYwykdkq7ilD7dPRz+gAAAIAM1k5Wir4wRnLccNh6sE84wPQoMyud8NJK5f4U3dwfNFm/GB84DOanABevEjx93G4bN8fqrjWrRJ8OnHA6ntW916nI31jrGTtlIwh86Z14vOqgC1raNmOEpSpd3xI1hwtotRSVkBaXOY1cwjnS6Xm0EpICGV/WD7q9AV1sQL92QQ== jdaniel@ehimeprefecture' \
  >> ~git/.ssh/authorized_keys

echo -e "Done!" 

\BLUE "Making Repository DIR"
  
  mkdir -p ~git/web-archive

echo -e "Done!" 

\BLUE "Creating Test Repository"

  mkdir -p ~git/web-archive/test.git 

  cd ~git/web-archive/test.git

  git --bare init # create a base repository

\BLUE "Creating Interactive GIT-Shell"

  mkdir -p ~git/git-shell-commands

  # ~git/git-shell-commands should exist and have read and execute access.
  git clone https://github.com/ehime/git-commands.git ~git/git-shell-commands

\BLUE "Locking GIT user"

  chown -R git:git ~git

# Prevent full login for security reasons
  chsh -s /usr/bin/git-shell git

echo -e "Locked."

\GREEN "Finished....."

  exit