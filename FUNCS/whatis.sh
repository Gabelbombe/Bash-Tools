#!/usr/bin/env bash

function whatis ()
{
    _GETOPTS=":abf"
    while getopts "${_GETOPTS}" opt ; do
      case $opt in
            abf) :                                                       ;;
            \?) echo "[err] Unsupported flag: -${OPTARG}" >&2 ; return 1 ;;
      esac
    done

    eval "ARG=\${${OPTIND}}"
    [ -z "${ARG}" ] && { echo -e "[err] Argument required..." ; return 1 ; }

    OPTIND=1 ; while getopts "${_GETOPTS}" opt ; do
      case $opt in
        a) echo -n "Alias  is: "  ; command -v     "${ARG}"  ;;
        b) echo -n "Binary is: "  ; /usr/bin/which "${ARG}"  ;;
        f) echo -n "Full list:\n" ; type -a        "${ARG}"  ;;
      esac
    done
}

## Test
ln -s /bin/ls /usr/local/bin
alias ls='/usr/local/bin/ls'
alias ll='ls -lAvh'

whatis -a ll ; echo -e "\n"
whatis -b ll ; echo -e "\n"
whatis -t ll ; echo -e "\n\n"

whatis -abt ll

## Cleanup
rm -f /usr/local/bin/ls ; unalias ll
