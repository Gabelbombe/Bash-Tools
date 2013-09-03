#!/bin/bash

clear; set -x

# using ssh-keys
#echo "Enter password: "
#read -s PAS

# cleanup
find -maxdepth 1 -type d ! -name '.*' |xargs rm -rf; # tmp

URL=https://github.com/ehime/Restful-MVC-Prototype/
SVN=svn+ssh://jdaniel@forge.erado.com/home/forge/svn/erado/saas/api/archiving/trunk

# current location
ROOT=`pwd`

# dirs
SVN_FOLDER="${ROOT}/svn"
GIT_FOLDER="${ROOT}/git"

# revs
ENDREV=`svn info $URL |grep Revision: | awk '{print $2}'`
CURREV=1

# blacklist
EXCLUDE=('.git' '.idea')
EXCLUDE_PATTERN=$(IFS='|'; echo "${EXCLUDE[*]}")
EXCLUDE_PATTERN=${EXCLUDE_PATTERN//./\\.}

  mkdir -p $SVN_FOLDER $GIT_FOLDER

echo -e "\nLinking SVN repo\n"

  cd $SVN_FOLDER
  svn co $SVN .

echo -e "\nDownloading GIT repo\n"

  cd $GIT_FOLDER
  git svn init -s $URL

  # now in technicolor
  git config --global color.ui "auto"

for (( r=$CURREV; r<$ENDREV+1; r++ ))
do

  git svn fetch -r $CURREV

  # move whitelists subversion folder
  find "$GIT_FOLDER" \
    -mindepth 1 \
    -maxdepth 1 \
    -regextype posix-egrep \
    -not -regex ".*/(${EXCLUDE_PATTERN})$" \
    -exec mv -t "$SVN_FOLDER" '{}' '+'

    # set opts for SVN logging
    CID=$(git log --format=oneline |awk '{print $1}')
    AUTHOR='Jd Daniel <jdaniel@erado.com>'
    DATE=$(git log --date=iso |grep 'Date' |awk -v N=2 '{sep=""; for (i=N; i<=NF; i++) {printf("%s%s",sep,$i); sep=OFS}; printf("\n")}')
    LOGMSG=$(git log --oneline |awk -v N=2 '{sep=""; for (i=N; i<=NF; i++) {printf("%s%s",sep,$i); sep=OFS}; printf("\n")}')


    # move to svn
    cd $SVN_FOLDER

    ADD=$(svn st |grep '?\|M' |awk '{printf "%s ", $2}'); [  -z "$ADD" ] && svn add $ADD
    REM=$(svn st |grep 'D\|!' |awk '{printf "%s ", $2}'); [  -z "$REM" ] && svn rm  $REM


  break # just on rev for now

done


exit