#!/bin/bash
# Optimize all database tables

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-09-17 @ 13:10:49

# REF : http://goo.gl/LgI3FD
# VER : Version 1.0

mysqlcheck --all-databases
mysqlcheck --all-databases -o
mysqlcheck --all-databases --auto-repair
mysqlcheck --all-databases --analyze