#!/bin/bash
# MongoDB installer for PHP && DEB based servers

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-10-17 @ 14:02:46
# VER : Version 1.04

clear
stty erase '^?'

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

: <<'END'
  PHP Installation
END

hash pecl 2>/dev/null || {

  packages=(make php5-dev php-pear libcurl3-openssl-dev) # test deps to make pecl

  for package in "${packages[@]}"; do

    # if missing dependancies $package, prep for installation...
    [ -z `dpkg --get-selections |awk '{print $1}' |grep -x $package` ] && apt-get install -y $package

  done

  pecl install mongo  # is now available as a package
  apache2ctl graceful # graceful restart
}

# test mongodb's so was installed correctly, AKA php_dir was not declared
INI=`php -i |grep 'Loaded Configuration File' |awk '{print $5}'` 
if [ -z `cat $INI |grep 'extension="mongo.so"'` ]; then
  echo -e '\n# MongoDB Installation SO\nextension="mongo.so"' >> $INI
fi

apache2ctl graceful # graceful restart

php -r 'phpinfo();' |grep -q 'mongo' # re stat, and end game...

# output
[ $? == 0 ] && echo -e '\n\E[37;42m'"\033[1mInstallation successful!\033[0m\n" \
            || firefox 'http://goo.gl/kfa2XO' # you broke the fuckin interwebs....

exit 0