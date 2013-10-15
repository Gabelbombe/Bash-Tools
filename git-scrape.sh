#!/bin/bash
# WARC File assembler
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-10-15 @ 15:36:12

clear; #set -x #debug

declare -r filename="$2" # early declaration for trap
CDIR=`pwd` # dir_path to local clone

function cleanup(){
  rm -rf "${CDIR}/$filename"
}

trap cleanup EXIT

#######################################################

function strtoupper (){
  if [ -n "$1" ]; then
    echo "$1" | tr '[:lower:]' '[:upper:]'
  else
    cat - | tr '[:lower:]' '[:upper:]'
  fi
}

function BLUE(){
  echo -e '\n\E[37;44m'"\033[1m${1}\033[0m\n"
}

function GREEN(){
  echo -e '\n\E[37;42m'"\033[1m${1}\033[0m\n"
}

function RED(){
  echo -e '\n\E[37;41m'"\033[1m${1}\033[0m\n"
}

# early var declaration
declare -r system=`strtoupper "$1"`
declare -r hostname='localhost'
declare -i used=0
declare -i elem=0

DATE=($(date +"%Y-%d-%m"))
TIME=($(date +"%T"))

  if [ ! -f "${filename}" ]; then
    \RED 'File does not exist, terminating....'
    tput sgr0 # reset
    exit
  fi

  \BLUE 'Reading input as array....'

  while IFS=$'\n' read -r LINE || [[ -n "$LINE" ]]; do

    ((elem++)) # start counter

    cd $CDIR # move back to homepath

    # if this is a bad domain name, exit with reason
    [ ! $(echo $LINE | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)') ] && exit

      # test the site
      curl -s --head $LINE | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null

      SITEEXISTS=$?
      DIREXISTS=0

      if [ '0' == $SITEEXISTS ]; then

        ARCDIR="web-archive/${LINE}"

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
          ssh git@$hostname "create ${LINE}" < /dev/null

          git clone git@$hostname:web-archive/${LINE}.git .
          git commit --allow-empty -m "Initialize..."

          # add branches
          echo -e "render\nstorage" | while read x; do
            git branch "$x"
            git push -u origin "$x"
          done
        fi

        hash CutyCapt 2> /dev/null || {
          \GREEN "Attempting to install CutyCapt...."

            wget "https://raw.github.com/ehime/bash-tools/master/cutycapt-installer-${system}.sh"

            chmod +x "cutycapt-installer-${system}.sh"

            # run it
            bash "cutycapt-installer-${system}.sh"
        }

        \BLUE 'Capturing website image....'

          CutyCapt --url="http://${LINE}"   \
            --out="static.png"                  \
            --max-wait=12500                    \
            --insecure

        echo -e "\tDone!"

        \BLUE 'Starting ARC compression...'

          echo -e "render\nstorage" | while read x; do

              \GREEN "Fetching ${x}"

              git checkout "$x"
              git pull origin "$x"

              touch "${LINE}.cdx"

              case $x in
                  'render' )

                    wget "${LINE}" -r -l INF -p           \
                      --adjust-extension                      \
                      --convert-links                         \
                      --no-check-certificate                  \
                      --warc-header="Operator: Web Archiver"  \
                      --warc-file="${LINE}"               \
                      --warc-dedup="${LINE}.cdx"          \
                      --warc-cdx=on 2> session.log
                  ;;

                  'storage' )
                    wget "${LINE}" -r -l INF -p           \
                      --adjust-extension                      \
                      --no-check-certificate                  \
                      --warc-header="Operator: Web Archiver"  \
                      --warc-file="${LINE}"               \
                      --warc-dedup="${LINE}.cdx"          \
                      --warc-cdx=on 2> session.log
                  ;;
              esac

              echo; git add .
              echo; git commit -am "Archiving ${x}: ${DATE} @ ${TIME}"
              echo; git push origin "$x"

          done
        ((used++))
      fi
  done <$filename

  git checkout render # reset

  if [[ `git show-branch master` ]]; then # kill our master ;)
    git branch -D master # master is local, so no need to push refs
  fi

\BLUE "used: ${used}/${elem} elements...."