#!/bin/bash

# If the user is not root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# install key
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

# create DEB source list
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

# install package
apt-get update && apt-get install -y mongodb-10gen

: <<'END'
  Configuring MongoDB

  These packages configure MongoDB using the /etc/mongodb.conf file in conjunction 
  with the control script. You will find the control script is at /etc/init.d/mongodb.
  
  This MongoDB instance will store its data files in the /var/lib/mongodb and its log 
  files in /var/log/mongodb, and run using the mongodb user account.

  Note: If you change the user that runs the MongoDB process, you will need to modify 
  the access control rights to the /var/lib/mongodb and /var/log/mongodb directories.
END

service mongodb restart

# PHP Installation

pecl install mongo

# test mongodb's so was installed correctly, AKA php_dir was not declared
INI=`php -i |grep 'Loaded Configuration File' |awk '{print $5}'` 
if [ -z `cat $INI |grep 'extension="mongo.so"'` ]; then
  echo -e "\n# MongoDB Installation SO\nextension="mongo.so" >> $INI
fi

# graceful restart
apache2ctl graceful && exit 1