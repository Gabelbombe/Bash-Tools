#!/bin/bash
# Optimize all database tables

# CPR : Jd Daniel :: Gabelbombe
# MOD : 2014-09-17 @ 13:10:49

# REF : http://goo.gl/LgI3FD
# VER : Version 1.1

read -p "Mysql User: " user
read -p "Mysql Pass: " pass

mysqlcheck -u"${user}" -p"${pass}" --all-databases
mysqlcheck -u"${user}" -p"${pass}" --all-databases -o
mysqlcheck -u"${user}" -p"${pass}" --all-databases --auto-repair
mysqlcheck -u"${user}" -p"${pass}" --all-databases --analyze