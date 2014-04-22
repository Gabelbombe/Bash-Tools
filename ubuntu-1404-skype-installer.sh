#!/bin/bash

# ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi

sh -c 'echo "deb http://archive.canonical.com/ quantal partner" >> /etc/apt/sources.list' 
apt-get update && apt-get install -y skype 