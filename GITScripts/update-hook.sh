#!/bin/bash
# GIT ACL Facade
#
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-12-08 @ 12:59:01
# VER : 1a

umask 002

verbose=false

GLOBIGNORE=*

function grant ()
{
  $verbose && echo -e >&2 "-Grant- \t $1"
  echo grant
  exit 0
}

function deny ()
{
  $verbose && echo -e >&2 "-Deny- \t $1"
  echo deny
  exit 0
}

function info ()
{
  $verbose && echo -e >&2 "-Info \t $1"
  echo info
  exit 0
}