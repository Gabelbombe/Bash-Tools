#!/bin/bash
# Git updater for RHEL systems

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-11-18 @ 10:29:06

# REF : http://goo.gl/ditKWu
# VER : Version 1.2

# calculate ver offset
function _ver_higher ()
{
    ver=`echo -ne "$1\n$2" |sort -Vr |head -n1`

    if [ "$2" == "$1" ]; then
            return 1
    elif [ "$2" == "$ver" ]; then
            return 0
    else
            return 1
    fi
}

# ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi

 # if version is higher than needed version. exit we're done here...
_ver_higher "$(git --version)" '1.7.1' || echo 'Version is adequate...' ; exit 0

# install deps
yum install -y perl-ExtUtils-MakeMaker gettext-devel expat-devel\
               curl-devel zlib-devel openssl-devel && cd /tmp

git clone git://git.kernel.org/pub/scm/git/git.git && cd git
make && make prefix=/usr install

git --version
exit 0