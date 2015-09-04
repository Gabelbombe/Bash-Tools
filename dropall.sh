#!/bin/bash
# Recursive file deletion

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-09-04 @ 09:02:52
# REF : https://goo.gl/bHkuWG
# VER : Version 1.0.0-dev

function dropall ()
{
  if [ -z "${1}" ]; then
    echo 'Requires a file to search for and erase...'; exit 1
  fi

  shopt -s extglob ## enable extglob
  for file in $(find . -type f); do
    if [ $1 == $(basename $file) ]; then
      rm -f $file |awk '{print substr($0,3)}'
    fi
  done
  shopt -u extglob ## disable extglob
}

dropall $1
