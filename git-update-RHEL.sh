#!/bin/bash
# Git updater for RHEL systems

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-11-18 @ 09:28:49
# VER : Version 1.0

# ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi

yum install -y perl-ExtUtils-MakeMaker gettext-devel expat-devel curl-devel zlib-devel openssl-devel
cd /usr/local/src

git clone git://git.kernel.org/pub/scm/git/git.git && cd git
make && make prefix=/usr install

git --ve