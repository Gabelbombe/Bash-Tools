#!/bin/bash
echo "Now installing CutyCapt"

  # APT/YUM install GIT base
  if hash apt-get 2>/dev/null; then

  	# install via APT
	sudo apt-get update -y && sudo apt-get install -y build-essential \
	xvfb xfs xfonts-scalable xfonts-100dpi libgl1-mesa-dri subversion \
	libqt4-webkit libqt4-dev g++

  elif hash yum 2>/dev/null; then
	su - # This works for CentOS 5.5 64bit systems

	# if $releasever does not show up we can use the below PY to read out....
	# python -c 'import yum, pprint; yb = yum.YumBase(); pprint.pprint(yb.conf.yumvar, width=1)'
	echo -e "#ATrpms\n[atrpms]\nname= CentOS-$releasever - ATrpms\nbaseurl=http://dl.atrpms.net/el$releasever-$basearch/atrpms/testing\ngpgcheck=1\ngpgkey=http://ATrpms.net/RPM-GPG-KEY.atrpms\nenabled=1" 
	>> /etc/yum.repos.d/CentOS-Base.repo

	rpm --import http://packages.atrpms.net/RPM-GPG-KEY.atrpms
	yum install -y qt47-devel qt47-webkit gcc-c++
  else
    echo "Installer needs to be either YUM or APT" 1>&2 ; exit 1
  fi

mkdir ~/scripts && cd ~/scripts
svn co https://svn.code.sf.net/p/cutycapt/code/ cutycapt && cd cutycapt/CutyCapt

# needs patching
echo 'Index: CutyCapt.hpp
===================================================================
--- CutyCapt.hpp	(revision 10)
+++ CutyCapt.hpp	(working copy)
@@ -1,4 +1,6 @@
 #include <QtWebKit>
+#include <QNetworkReply>
+#include <QSslError>
 
 #if QT_VERSION >= 0x050000
 #include <QtWebKitWidgets>
' > CutyCapt.patch

patch -p0 -i CutyCapt.patch

qmake
make

ln -s ~/scripts/cutycapt/CutyCapt/CutyCapt /bin
