#!/bin/bash
# Git server setup for DEB/RHEL systems

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-06-20 @ 11:32:41
# VER : Version 1.4.0

## Run:
## cd /tmp && wget https://raw.githubusercontent.com/ehime/Bash-Tools/master/git-server-setup.sh
## sudo chmod a+x git-server-setup.sh && sudo bash git-server-setup.sh

# functions
function BLUE() 
{
  echo -e '\n\E[37;44m'"\033[1m${1}\033[0m\n"
}

function GREEN() 
{
  echo -e '\n\E[37;42m'"\033[1m${1}\033[0m\n"
}

reset

# ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
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

  # if user already exists, warn and exit
  [[ -z "$(getent passwd git)" ]] || {
    echo 'User exists...' ; exit 1
  }

  # create user and set dir skeleton
  [ -d "/home/git" ] || useradd     \
    --create-home                   \
    --skel      /dev/null           \
    --home-dir  /home/git           \
    --shell     /bin/bash           \
    --comment   'Local Archiver'    \
  git

  chmod -R 0750 /home/git

\BLUE "Adding authorized_keys file"

  mkdir -p /home/git/.ssh 
  chmod 0700 /home/git/.ssh
  
  touch /home/git/.ssh/authorized_keys
  chmod 0600 /home/git/.ssh/authorized_keys

  ## messed up because you're su when this happens
  ssh-keygen -f ~/.ssh/git_dsa -t dsa -N ''

  echo -e "IdentityFile\nIdentityFile ~/.ssh/git_dsa" >> config

  # create a root key
  cat ~/.ssh/git_dsa.pub >> /home/git/.ssh/authorized_keys

  ## better if you just ssh -i ~/.ssh/git_dsa git@localhost

  BLUE "Root key is: $(cat ~/.ssh/git_dsa.pub)"

echo -e "Done!" 

\BLUE "Creating Test Repository"

  repository='/home/git/repositories/test.git'

  # create a test repository
  mkdir -p ${repository} && cd ${repository}

  git --bare init # create a base repository

\BLUE "Adding interactive GIT-Shell commands"

  # /home/git/git-shell-commands should exist and have read and execute access.
  git clone https://github.com/ehime/git-commands.git /home/git/git-shell-commands

\BLUE "Locking GIT user"

  # change ownership from root
  chown -R git:git /home/git

  # Prevent full login for security reasons
  chsh -s /usr/bin/git-shell git

echo -e "Locked."

\BLUE "GIT testing version"

  majmin=$(git --version | awk '{ print $3 }' | awk -F'.' '{print $2$3}') 
  if [ $major < 74 ]; then

  cd /tmp && wget https://raw.github.com/ehime/bash-tools/master/git-update-RHEL.sh
  chmod +x git-update-RHEL.sh 

  bash git-update-RHEL.sh # run it
  else
    \GREEN 'Versions ok..'
  fi
\BLUE "Setting up GIT user UID and Email"

  # use (unique) system variables to start this
  git config --global user.name \""$(echo `cat /sys/class/dmi/id/product_uuid`"-"`hostname`)"\"
  git config --global user.email \"`whoami`@`hostname`\"

\GREEN "Finished....."

exit 0
