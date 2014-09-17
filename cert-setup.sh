#!/bin/bash
# Self-Signed SSL Certificate with Apache
#
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-06-16 @ 11:48:48
# VER : 1a

## ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi

## Generate a Self-Signed Certificate
a2enmod ssl
mkdir -p /etc/apache2/ssl
openssl req -new -x509 -days 365 -nodes -out /etc/apache2/ssl/apache.pem -keyout /etc/apache2/ssl/apache.key