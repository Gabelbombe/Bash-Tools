#!/bin/bash
# WARC File assembler
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-10-02 @ 11:36:59

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
declare -r HOSTNAME='localhost'
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

  declare -i ELEM=0

  while IFS=$'\n' read -r LINE || [[ -n "$LINE" ]]; do

    # skip comments
    [[ "$LINE" =~ ^#.*$ ]] && continue

      ((ELEM++)) # counter

    # break into workable
    REGEXP="^([0-9]+)?\s(.*)$"

    [[ "${LINE}" =~ $REGEXP ]] && CRONTIME="${BASH_REMATCH[1]}" && WGDOMAIN="${BASH_REMATCH[2]}"

    cd $CDIR # move back to homepath

    PROPERDOM=$(echo $WGDOMAIN | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)')

    if [ $PROPERDOM ]; then

      # test the site
      curl -s --head $WGDOMAIN | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null

      SITEEXISTS=$?
      DIREXISTS=0

      if [ '0' == $SITEEXISTS ]; then

        ARCDIR="web-archive/${WGDOMAIN}"

        echo -e "\tArchive DIR: ${ARCDIR}"
        if [ ! -d "${ARCDIR}" ]; then
          DIREXISTS=1 #doesn't exsist set flag
          mkdir -p "${ARCDIR}"
        fi

        cd "${ARCDIR}"

        if [ '1' == $DIREXISTS ]; then

          echo -e "\tCreating server repository"

          # ssh reads from standard input, therefore it eats all our remaining lines.
          # To fix this we can just connect its standard input to nowhere....
          ssh git@$HOSTNAME "create ${WGDOMAIN}" < /dev/null

          git clone git@$HOSTNAME:web-archive/${WGDOMAIN}.git .
          git commit --allow-empty -m "Initialize..."

          # add branches
          echo -e "render\nstorage" | while read x; do
            git branch "$x"
            git push -u origin "$x"
          done
        fi

        hash CutyCapt 2> /dev/null || {
          \GREEN "Attempting to install CutyCapt...."

            wget "https://raw.github.com/ehime/bash-tools/master/cutycapt-installer-${SYSTEM}.sh"

            chmod +x "cutycapt-installer-${SYSTEM}.sh"

            # run it
            bash "cutycapt-installer-${SYSTEM}.sh"
        }

        \BLUE 'Capturing website image....'

          CutyCapt --url="http://${WGDOMAIN}"   \
            --out="static.png"                  \
            --max-wait=12500                    \
            --insecure

        echo -e "\tDone!"

        \BLUE 'Starting ARC compression...'

          echo -e "render\nstorage" | while read x; do

              \GREEN "Fetching ${x}"

              git checkout "$x"
              git pull origin "$x"

              touch "${WGDOMAIN}.cdx"

              case $x in
                  'render' )

                    wget "${WGDOMAIN}" -r -l INF -p           \
                      --adjust-extension                      \
                      --convert-links                         \
                      --no-check-certificate                  \
                      --warc-header="Operator: Web Archiver"  \
                      --warc-file="${WGDOMAIN}"               \
                      --warc-dedup="${WGDOMAIN}.cdx"          \
                      --warc-cdx=on 2> session.log
                  ;;

                  'storage' )
                    wget "${WGDOMAIN}" -r -l INF -p           \
                      --adjust-extension                      \
                      --no-check-certificate                  \
                      --warc-header="Operator: Web Archiver"  \
                      --warc-file="${WGDOMAIN}"               \
                      --warc-dedup="${WGDOMAIN}.cdx"          \
                      --warc-cdx=on 2> session.log
                  ;;
              esac

              echo; git add .
              echo; git commit -am "Archiving ${x}: ${DATE} @ ${TIME}"
              echo; git push origin "$x"

          done
        ((USED++))
      fi
    fi
  done <$FILENAME

  git checkout render # reset

  if [[ `git show-branch master` ]]; then # kill our master ;)
    git branch -D master # master is local, so no need to push refs
  fi

\BLUE "Used: ${USED}/${ELEM} elements...."