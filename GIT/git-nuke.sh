#!/usr/bin/env bash -xe

##Delta and get files
##Uses escape to allow for all weird combinations of quotes in arguments

case `basename $0 .sh` in
  deledit)    eflag="-e" ;;
esac

sflag="-s"
for arg in "$@" ; do
  case "$arg" in
    -r*)    gargs="$gargs `escape \"$arg\"`"
            dargs="$dargs `escape \"$arg\"`"
            ;;

    -e)     gargs="$gargs `escape \"$arg\"`"
            sflag=""
            eflag=""
            ;;

    -*)     dargs="$dargs `escape \"$arg\"`"
            ;;

    *)      gargs="$gargs `escape \"$arg\"`"
            dargs="$dargs `escape \"$arg\"`"
            ;;
  esac
done
eval delta "$dargs" && eval get $eflag $sflag "$gargs"

for nuke in "$@" ; do
  if []

done
