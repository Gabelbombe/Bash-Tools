#!/bin/bash
# CPR : Jd Daniel :: Gabelbombe
# MOD : 2014-04-04 @ 13:13:29
# VER : 1.0
#
# Create a swap disk otf...

## ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi

## create
mkswap /autoswapfile
dd if=/dev/zero of=/autoswapfile bs=1M count=1024

## ownership
chown root:root /autoswapfile
chmod 0600 /autoswapfile

## activate
swapon autoswapfile
swapoff -a
swapon  -a

## Update fstab
echo -e "/autoswapfile\t swap\t swap\t defaults\t 0\t0" >> /etc/fstab

## verify
free -m  	&& sleep 2
swapon -s 	&& sleep 2

grep -i --color swap /proc/meminfo
