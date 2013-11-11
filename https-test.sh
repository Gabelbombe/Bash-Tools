#!/bin/bash

site='tldp.org'		# http
#site='erado.com'	# https

# are you SSL verified or not ... ?
[ '' != "$(echo $(echo ^D | telnet $site https 2> /dev/null) | awk '{print $3}')" ] \
	&& protocol='https' \
	|| protocol='http'

echo $protocol
