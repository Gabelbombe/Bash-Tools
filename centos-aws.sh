#!/bin/bash
# Setup a blank Centos 6.4 Development server
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-05-08 @ 09:59:25
# INP : $ ./centos-aws.sh


###############################
###############################


local chance=()


## Install basics
sudo yum install -y nano wget curl git rsync lsyncd openssh mutt expect


## Installing Apache
sudo yum install -y httpd

	service httpd stop							#terminate

## Installing PHP
sudo yum groupinstall -y "PHP Support"
sudo yum -y install php-{soap,mcrypt}			#extras


## Installing Mysql
sudo yum grouplist |grep -i mysql 				#find
sudo yum groupinfo "MySQL Database"				#info
sudo yum groupinstall -y "MySQL Database*"  	#install


## Verify Mysql
rpm -qa |grep -i mysql |md5sum |awk '{print$1}' #valid: fa9ff66d8d7f053fc8dc06f3b4ec0add
grep mysql /etc/passwd |md5sum |awk '{print$1}' #valid: c4bea80272faf18d6abc419e2ca23ed6
grep mysql /etc/group  |md5sum |awk '{print$1}' #valid: bb110b12c73920bcf4b6675c0ec6397c
mysqladmin --version   |md5sum |awk '{print$1}' #valid: 4c1b4a63602f6098e550945c307386fa


## Generate several heavy passwords, randomly add then select one
for generate in $(apg -a 1 -m 64 -n 10); do
  chance+=( $(echo $generate |sed "s/[\"']//g"|fold -w32 |head -n1) )
done


# Seed random generator
RANDOM=$$$(date +%s)
passwd=${chance[$RANDOM % ${#chance[@]} ]}


## Tighten Mysql security
/usr/bin/expect -c 'expect "\n" { eval
  spawn bash /usr/bin/mysql_secure_installation
  expect "current password"
  send "\n" 
  interact
  expect "Set root password"
  send "Y\n"
  expect "New password"
  send "$passwd\n"
  expect "Re-enter new password"
  send "$passwd\n"
  expect "Remove anonymous users"
  send "Y\n"
  expect "Disallow root login remotely"
  send "N\n"
  expect "Remove test database"
  send "Y\n"
  expect "Reload privilege tables"
  send "Y\n"
}'

## Notify
echo "$passwd" |mutt -s 'New MYSQl Root Passwd' -- dodomeki@gmail.com

	service httpd start 						#restart