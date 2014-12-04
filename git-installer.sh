#!/bin/bash
# EPEL (Extra Package Library) Installer for RHEL based systems

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-11-20 @ 14:00:34
# INP : ./git-installer.sh

## ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi

cd /tmp
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -Uvh ./epel-release-5-4.noarch.rpm

yum install git