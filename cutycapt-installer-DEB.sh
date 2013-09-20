#!/bin/bash
echo "Now installing CutyCapt"

sudo apt-get update -y
sudo apt-get install -y build-essential
sudo apt-get install -y xvfb
sudo apt-get install -y xfs xfonts-scalable xfonts-100dpi
sudo apt-get install -y libgl1-mesa-dri
sudo apt-get install -y subversion libqt4-webkit libqt4-dev g++

mkdir ~/scripts
cd ~/scripts
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
