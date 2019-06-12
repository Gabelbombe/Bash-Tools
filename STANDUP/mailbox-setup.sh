#!/bin/bash
# Set up a local mailer and inbox with MUTT
#
# CPR : Jd Daniel :: Gabelbombe
# MOD : 2014-06-16 @ 11:48:48
# VER : 1a

## ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi


apt-get install -y mutt mailutils
touch /var/mail/$USER
chown $USER:mail /var/mail/$USER

chmod o-r /var/mail/$USER
chmod g+rw /var/mail/$USER

read -p 'Send testmail to: ' email

echo "Test email from $(echo $USER)" | mutt -s 'Working' -- $email
exit 0