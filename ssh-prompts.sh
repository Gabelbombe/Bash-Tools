#!/bin/bash
# Detects of server accepts connections

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-09-04 @ 09:51:16
# REF : https://goo.gl/
# VER : Version 1.0.0-dev

################################################################################
################################################################################

## foobar.com           prompt: passwd
## stackoverflow.com    prompt: none
## github.com           prompt: priv key denied

declare -a servers=(foobar.com stackoverflow.com github.com)
declare -i port=22

for server in ${servers[@]} ; do
  nc -w 3 -z $server $port && {
    echo Success: $port
  } || {
    echo Failure: $port
  }
done
