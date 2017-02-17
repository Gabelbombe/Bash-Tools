#!/bin/bash
function ConvertToMp4() {
  if [ "x$1" != "x" ] ; then
    cd $1
  fi

  for file in *.flv ; do
    local bname=$(basename "$file" .flv)
    local mp4name="$bname.mp4"
    ffmpeg -i "$file" "$mp4name"
    rm -f "$file" #housecleaning
  done
}
ConvertToMp4 "$1"
