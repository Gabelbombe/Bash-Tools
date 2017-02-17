#!/bin/bash

function bs()
{
  [ -f "/Users/$(whoami)/.bash_${1}" ] && {
    source "/Users/$(whoami)/.bash_${1}"
    echo -e "[info] Refreshed .bash_${1}"
  } || {
    echo -e "[err] "/Users/$(whoami)/.bash_${1}" does not exit"
  }
}
