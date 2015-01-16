#!/bin/bash
# HipHop VM installer for Ubuntu 14.04 x64 LTS

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-01-12 @ 14:28:11
# VER : Version 2

echo "==> Disabling Firewall..."
sudo ufw disable

echo "==> Updating..."
sudo apt-get -y update
sudo apt-get -y upgrade

echo "==> Creating install dir...."
ROOT='/tmp/HHVM-Install'
mkdir $ROOT && cd $_

## Get HipHop source code....
echo "Building the HipHop Virtual Machine..."
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
# installs add-apt-repository
sudo apt-get install software-properties-common
sudo add-apt-repository 'deb http://dl.hhvm.com/ubuntu trusty main'
sudo apt-get update
sudo apt-get install -y hhvm

echo "==> Reenabling Firewall"
sudo ufw enable
