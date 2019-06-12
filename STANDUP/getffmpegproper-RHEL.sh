#!/bin/bash
# RPM ffmpeg installer

# CPR : Jd Daniel :: Gabelbombe
# MOD : 2013-25-06 @ 10:45:38

# $ ./getffmpegproper-arch

su -c "curl http://download.opensuse.org/repositories/home:/satya164:/fedorautils/Fedora_18/home:satya164:fedorautils.repo -o /etc/yum.repos.d/fedorautils.repo && yum install fedorautils"
su -c 'yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-18.noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-18.noarch.rpm'
sudo yum -y install gstreamer gstreamer-ffmpeg gstreamer-plugins-bad gstreamer-plugins-bad-free gstreamer-plugins-bad-nonfree gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-ugly ffmpeg yasm yasm-devel