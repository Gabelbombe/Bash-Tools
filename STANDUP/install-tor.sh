#!/bin/bash
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-06-13 @ 16:23:53
# VER : 1.0
#
# Install TOR on Debian based systems


su -
LOCAL $DISTRO=$(lsb_release -a |grep -i 'description' |awk '{print$3}')

echo "deb     http://deb.torproject.org/torproject.org ${DISTRO} main"
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

apt-get update && apt-get install tor deb.torproject.org-keyring