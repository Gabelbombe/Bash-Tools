#!/bin/bash

function get_latest_stable()
{
  local url="${1}"
  local name="$2"

  echo "${url%/}/${name}-$(curl -s "${url}" |grep -oP "href=.${name}-\K[0-9]+\.[0-9]+\.[0-9]+" |sort -t. -rn -k1,1 -k2,2 -k3,3 | head -1).dmg"
}

get_latest_stable 'http://downloads.puppetlabs.com/mac/' 'facter'
get_latest_stable 'http://downloads.puppetlabs.com/mac/' 'hiera'
get_latest_stable 'http://downloads.puppetlabs.com/mac/' 'puppet'
