#!/usr/local/bin/bash
# Ansible runner

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-09-04 @ 09:51:16
# REF : https://goo.gl/
# VER : Version 1.0.0-dev

## If directory doesn't exist, create it and the files that are required
[ ! -d /opt/ansible ] || [ ! -f '/opt/ansible/ec2.ini' ] || [ ! -f '/opt/ansible/ec2.py' ] && {
  mkdir -p /opt/ansible

  curl -sSL https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini /opt/ansible/ec2.ini
  curl -sSL https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py  /opt/ansible/ec2.py

  chmod 0755 /opt/ansible/ec2.py
}

## if ansible isn't already an alias of something, alias it
[ 'x' != "$(which ansible |grep 'aliased')x" ] && {
  export alias ansible="$(which ansible |head -n1 |awk '{print$3}') -i /opt/ansible/ec2.py"
}
