#!/bin/bash
# GIT ACL Facade
#
# CPR : Jd Daniel :: Gabelbombe
# MOD : 2014-12-08 @ 12:59:01
# VER : 1a

umask 002

VERBOSE=true
GLOBIGNORE=*

function grant ()
{

  $VERBOSE && { 
    echo -e >&2 "\e[95m-Grant- \t ${1}\e[39m\n"
  } || {
    echo grant
  }
  exit 0
}

function deny ()
{
  $VERBOSE && {
    echo -e >&2 "\n\e[91m-Deny-  \t ${1}\e[39m\n"
  } || {
    echo deny
  }
  exit 0
}

function info ()
{
  $VERBOSE && echo -e >&2 "\e[93m-Info-  \t ${1}\e[39m"
}

case "${1}" in 
  refs/tags/*)
    git rev-parse --verify "${1}" && deny >/dev/null "You cannot overwrite an existing branch..."
  ;;

  refs/heads/*)
    if expr "${2}" : '0*$' >/dev/null; then
      info "The branch '${1}' is new..."
    else 
      gmb=$(git merge-base "${2}" "${3}")
      case "${gmb},${2}" in
        "${2},${gmb}")
          info "Update is Fast-Forward..."
        ;;
        *)
          info "This is not a Fast-Forward update..."
          noff=y
        ;;
      esac
    fi
  ;;

  *)
    deny >/dev/null "Branch is not under refs/heads or refs/tags..."
  ;;
esac

allowed_users_file="${GIT_DIR}/info/allowed-users"
username="$(id -u -n)"
info "The user is: ${username}"

if test -f "${allowed_users_file}"; then
    while read heads user_patterns; do

    done < <($allowed_users_file |grep -v '^#' |grep -v '^$')
fi

deny >/dev/null "There are no more rules to check. Denying access..."