#!/bin/bash
echo "Now installing CutyCapt"
echo "This works for CentOS 5.5 64bit systems"

su -

echo "#ATrpms
[atrpms]
name= CentOS-$releasever - ATrpms
baseurl=http://dl.atrpms.net/el$releasever-$basearch/atrpms/testing
gpgcheck=1
gpgkey=http://ATrpms.net/RPM-GPG-KEY.atrpms
enabled=1
" > /etc/yum.repos.d/CentOS-Base.repo

rpm --import http://packages.atrpms.net/RPM-GPG-KEY.atrpms

yum install -y qt47-devel qt47-webkit gcc-c++

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
