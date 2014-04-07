#!/bin/bash
# CPR : Jd Daniel :: http://goo.gl/Yejho4
# MOD : 2014-04-07 @ 12:09:01
# VER : 0.2a

[ -z "${1}" ] && {
  cd ~/www/mean/BenApp/
} || {
  cd "${1}"
}

echo -e "\nErasing contents of: $(pwd)"
read -p "Directory correct [Y/n]: " dir

[ 'y' == "$(echo ${dir} | awk '{print tolower($0)}')" ] || {
  read -p "Enter absolute path: " dir
  [ -d "$dir" ] && { cd ${dir} ; }
}

rm -rf *    && git reset --hard HEAD
npm install && bower install

