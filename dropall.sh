#!/bin/bash

function dropall ()
{
  if [ -z "${1}" ]; then
    echo 'Requires a file to search for and erase...'; exit 1
  fi

  for file in $(find . -type f); do
    if [ $1 == $(basename $file) ]; then
      rm -f $file |awk '{print substr($0,3)}'
    fi
  done
}

dropall $1
