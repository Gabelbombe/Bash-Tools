#!/bin/bash
# Recursive file deletion

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-09-04 @ 09:21:03
# REF : https://goo.gl/bHkuWG
# VER : Version 1.0.1-dev

## Example:
## cd /tmp && mkdir -p foo/bar/baz
## shopt -s globstar ; for d in **/*/; do touch -- "$d/.test"; done
## ls -aR foo ; ./dropall.sh .test ; ls -aR foo
## ## ## ##
## ## ## ##

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
