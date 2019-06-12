#!/bin/bash
# CPR : Jd Daniel :: Gabelbombe
# MOD : 2014-04-04 @ 13:13:29
# VER : 1.0
#
# My typical ENV Setup for DEB based systems...

## ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi


## MariaDB

  # remove existing MySQL packages if any
  apt-get purge -y mysql* 

  # remove unwanted packages.
  apt-get autoremove -y

  # add PPA
  apt-get install -y software-properties-common
  apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
  add-apt-repository 'deb http://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/repo/5.5/ubuntu saucy main'

  # install MariaDB
  apt-get update && apt-get install -y mariadb-server mariadb-client

  # check version
  mysql -v


## Apache

  # install Apache
  apt-get install -y apache2

  # update apache2.conf
  awk 'p&&!NF{print "\nServerName localhost";p=0}/# Global configuration/{p=1}1' /etc/apache2/apache2.conf \
  > /tmp/apache2.conf 

  ## test if empty of exit
  [[ ! -s "/tmp/apache2.conf" ]] && {
     sudo mv /tmp/apache2.conf /etc/apache2
  } || {
   echo -e "\n\nERROR: could not AWK Apache configuration file correctly, exiting..."
   exit 1
  }

  service apache2 reload

  # apache2ctl -M |sort

  ## common modules
  ## https://www.digitalocean.com/community/articles/how-to-install-configure-and-use-modules-in-the-apache-web-server

    # pagespeed (deb x64): config located at "/etc/apache2/mods-available/pagespeed.conf"
    cd /tmp && wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
    sudo dpkg -i mod-pagespeed-*.deb
    sudo apt-get -f install
    sudo service apache2 reload

    # rewrite
    a2enmod rewrite
    service apache2 reload

    # proxy 
    a2enmod proxy
    service apache2 reload

    # log debugger
    a2enmod log_debug
    service apache2 reload

    # sed
    a2enmod sed
    service apache2 reload

  # errors from apache2 -M
  # AH00111: Config variable ${APACHE_LOCK_DIR} is not defined
  # AH00111: Config variable ${APACHE_PID_FILE} is not defined
  # AH00111: Config variable ${APACHE_RUN_USER} is not defined
  # AH00111: Config variable ${APACHE_RUN_GROUP} is not defined
  # AH00111: Config variable ${APACHE_LOG_DIR} is not defined
  # AH00111: Config variable ${APACHE_LOG_DIR} is not defined
  # AH00526: Syntax error on line 76 of /etc/apache2/apache2.conf:
  # Invalid Mutex directory in argument file:${APACHE_LOCK_DIR}

  # check version
  apache2 -v


## PHP 5.5

  # actual install stuff 
#  sudo add-apt-repository ppa:ondrej/php5
#  sudo apt-get update sudo apt-get upgrade
#  sudo apt-get install -y php5

  # add my common packages
  ext5=( fpm tokyo-tyrant gearman cli curl geoip mcrypt xmlrpc json tidy mongo mysql odbc xdebug dbg memcache memcached apcu xcache gd mysql)
  for pkg in "${ext5[@]}"; do
    apt-get install -y php5-${pkg}
  done

  service apache2 restart

  php -v