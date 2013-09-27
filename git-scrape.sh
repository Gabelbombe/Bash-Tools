#!/bin/bash
# WARC File assembler
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-19-09 @ 12:22:43

clear; #set -x #debug

function strtoupper () {
  if [ -n "$1" ]; then
echo "$1" | tr '[:lower:]' '[:upper:]'
  else
cat - | tr '[:lower:]' '[:upper:]'
  fi
}

function BLUE() {
  echo -e '\n\E[37;44m'"\033[1m${1}\033[0m\n"
}

function GREEN() {
  echo -e '\n\E[37;42m'"\033[1m${1}\033[0m\n"
}

function RED() {
  echo -e '\n\E[37;41m'"\033[1m${1}\033[0m\n"
}

# early var declaration
declare -r SYSTEM=`strtoupper "$1"`
declare -r FILENAME="$2"
declare -i USED=0

CDIR=`pwd` # dir_path to local clone

DATE=($(date +"%Y-%d-%m"))
TIME=($(date +"%T"))

  if [ ! -f "${FILENAME}" ]; then
    \RED 'File does not exist, terminating....'
    tput sgr0 # reset
    exit
fi

  \BLUE 'Reading input as array....'

  declare -a ARRAY
  declare -i ELEM=0

  while IFS=$'\n' read -r LINE || [[ -n "$LINE" ]]; do

    # skip comments
    [[ "$LINE" =~ ^#.*$ ]] && continue

    # break into workable
    REGEXP="^([0-9]+)?\s(.*)$"
    [[ "${LINE}" =~ $REGEXP ]] && CRONTIME="${BASH_REMATCH[1]}" && WGDOMAIN="${BASH_REMATCH[2]}"

    cd $CDIR # move back to homepath

    PROPERDOM=$(echo $WGDOMAIN | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)')

    if [ $PROPERDOM ]; then

      # test the site
      curl -s --head $WGDOMAIN | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null

      declare -i SITEEXISTS=$?
      declare -i DIREXISTS=0

      if [ '0' == $SITEEXISTS ]; then

        ARCDIR="web-archive/${WGDOMAIN}"

        echo -e "\tArchive DIR: ${ARCDIR}"
        if [ ! -d "${ARCDIR}" ]; then
          DIREXISTS=0 #doesn't exsist set flag
          mkdir -p "${ARCDIR}"
        fi

        cd "${ARCDIR}"

        echo -e "\tCreating server repository"

        if [ '0' == $DIREXISTS ]; then
          ssh git@localhost "create ${WGDOMAIN}"

          git init .

          # cdx call script
          touch "${WGDOMAIN}.cdx"

          # add branches
          echo 'view archive' | while read x; do echo $( git branch "$x" & )  ; done

          git add "${WGDOMAIN}.cdx" && git 
        fi

        \BLUE 'Starting ARC compression...'

          :' C-BLOCK
            wget "$WGDOMAIN" -r -l INF -k -p \
            --no-check-certificate \
            --strict-comments \
            --warc-file="${WGDOMAIN}"
          '

        hash CutyCapt 2>/dev/null || {
          \GREEN "Attempting to install CutyCapt...."
          
            wget "https://raw.github.com/ehime/bash-tools/master/cutycapt-installer-${SYSTEM}.sh"

            chmod +x "cutycapt-installer-${SYSTEM}.sh"

            # run it
            bash "cutycapt-installer-${SYSTEM}.sh"
        }

          \GREEN 'Capturing website image....'
          CutyCapt --url="$WGDOMAIN" --out="static-view.png"

        ((USED++))
    fi

done <$FILENAME

\BLUE "Used: ${USED}/${#ARRAY[@]} elements...."