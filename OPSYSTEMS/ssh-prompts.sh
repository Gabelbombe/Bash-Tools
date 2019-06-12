#!/bin/bash
# Detects if server accepts connections

# CPR : Jd Daniel :: Gabelbombe
# MOD : 2015-09-04 @ 09:51:16
# REF : https://goo.gl/a5ZUqx
# VER : Version 1.0.1-dev

################################################################################
################################################################################

## foobar.com           prompt: passwd
## stackoverflow.com    prompt: none
## github.com           prompt: priv key denied

declare -a servers=(foobar.com stackoverflow.com github.com)
declare -i port=22

for server in ${servers[@]} ; do
  nc -w 3 -z $server $port && {
    echo Success: ${server}:${port}
  } || {
    echo Failure: ${server}:${port}
  }
done
