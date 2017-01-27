#!/usr/local/env bash
# Converter for GitHub to Subversion Repositories

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2017-01-26 @ 19:33:59
# VER : Version 1c

## Uncomment set to debug

clear ;                 # set -x #debug
REPO={THE_REPO_ROOT} in # svn+ssh://user@domain.com/api/svn_name

## if you want to burn and rebuild your repo, uncomment below
#
#echo "Burning Repo..."
#svn rm    $REPO/{trunk,tags,branches} -m "Burning..."

#echo "Rebuilding Repo...."
#svn mkdir $REPO/{trunk,tags,branches} -m "Rebuilding..."

# cleanup
find -maxdepth 1 -type d ! -name '.*' |xargs rm -rf; # tmp

# the Github SVN url
URL={THE_SVN_URL} # https://github.com/user/repo/

# use the trunk, branch, etc... I'm using the trunk
SVN="${REPO}/trunk"

# dirs
SVN_FOLDER=`pwd`"/svn"
GIT_FOLDER=`pwd`"/git"


# revs
ENDREV=`svn info $URL |grep Revision: |awk '{print $2}'`
CURREV=1

  mkdir -p $SVN_FOLDER $GIT_FOLDER

echo -e "\nLinking SVN repo\n"

  cd $SVN_FOLDER
  svn co $SVN .

echo -e "\nDownloading GIT repo\n"

  cd $GIT_FOLDER
  git svn init -s $URL


  for (( REVISION=$CURREV; REVISION<$ENDREV+1; REVISION++ ))
  do

    cd $GIT_FOLDER

    echo -e "\n---> FETCHING: ${REVISION}\n"

    git svn fetch -r$REVISION;                echo -e "\n"
    git rebase `git svn find-rev r$REVISION`; echo -e "\n"

    # STATUS: git log -p -1 `git svn find-rev r19` --pretty=format: --name-only --diff-filter=A | sort -u
    ADD=$(git log -p -1 `git svn find-rev r19` --pretty=format: --name-only --diff-filter=A |awk '{printf "%s ", $1}')
    MOD=$(git log -p -1 `git svn find-rev r19` --pretty=format: --name-only --diff-filter=M |awk '{printf "%s ", $1}')
    DEL=$(git log -p -1 `git svn find-rev r19` --pretty=format: --name-only --diff-filter=D |awk '{printf "%s ", $1}')

      # copy new files
      for i in $ADD
      do
         cp --parents $i $SVN_FOLDER/
      done


      # copy modified files
      for i in $MOD
      do
         cp --parents $i $SVN_FOLDER/
      done


    # set opts for SVN logging
    HASH=$(git log -1 --pretty=format:'Hash: %h <%H>')
    AUTHOR='Jd Daniel <dodomeki@gmail.com>'  # or $(git log -1 --pretty="%cn <%cE>")

    TMPDATE=$(git log -1 --pretty=%ad --date=iso8601)
    DATE=$(date --date "$TMPDATE" -u +"%Y-%m-%dT%H:%M:%S.%N" |sed 's/.....$/Z/g')

    LOGMSG=$(git log -1 --pretty=%s)

    # move to svn
    cd $SVN_FOLDER


    # burn file if it exists....
    if [ "$DEL" != "" ]; then
      for i in $DEL
      do
         test -f $i && svn --force rm $i
      done
    fi

    # first round of additions....
    [ -z "$ADD" ] || svn --force add $ADD
    [ -z "$MOD" ] || svn --force add $MOD


    # try 2 for adding in case we missed ? files
    ADDTRY=$(svn st . |grep "^?" |awk '{print $2}')
    [ -z "$ADDTRY" ] || svn --force add $ADDTRY

    # do commit
    svn ci -m "$LOGMSG"$'\n\n'"$HASH"

    # servers pre-revprop-change
    #  cp hooks/pre-revprop-change.tmpl pre-revprop-change; chmod +x pre-revprop-change
    #  if [ "$ACTION" = "M" -a "$PROPNAME" = "svn:author" ]; then exit 0; fi
    #  if [ "$ACTION" = "M" -a "$PROPNAME" = "svn:date" ]; then exit 0; fi
    #  echo "Changing revision properties other than svn:log, svn:author and svn:date is prohibited" >&2

    # change this commits author and date
    svn propset --revprop -r HEAD svn:author "$AUTHOR"
    svn propset --revprop -r HEAD svn:date   "$DATE"

  done

exit
