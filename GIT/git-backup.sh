#!/usr/local/bin/bash
# ORG backup script

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-08-04 @ 16:53:01
# REF : https://goo.gl/Z38oBh
# VER : Version 1.1.0-dev

# REQ : Bash 4.3+

################################################################################
################################################################################

repository=''
readonly random"=$(date |md5sum |awk '{print$1}')"
readonly tmpdir="/tmp/$random"

function print_usage()
{
  echo -e '
  Parameter usage: git-backup.sh [--help] [--to=<git-repo>] [--from=<git-repo>] [--user=<github-username>] [--pass=<github-password>]

  Parameters:
  -t  --to    Repository archiving to
  -f  --from  Repository archiving and removing
  -u  --user  Github username for API connection
  -p  --pass  Github password for API connection

  Example usage:
  git-backup.sh -u ehime -p "secure password" \
  -f git@github.com:ehime/Bash-Tools.git      \
  -t git@github.com:ehime/Cold-Storage.git
  '
}

## Following requires modern GNU bash 3.2 WILL FAIL....
if (shopt -s nocasematch; [[ $1 = @(-h|--help) ]]); then
  print_usage ; exit 1
else
  while [[ $# -gt 0 ]]; do
    opt="$1" ; shift ;
    current_arg="$1"
    if [[ "$current_arg" =~ ^-{1,2}.* ]]; then
      echo "=> You may have left an argument blank. Double check your command."
    fi
    case "$opt" in
      "-t"|"--to"         ) to="$1"; shift   ;;
      "-f"|"--from"       ) fr="$1"; shift   ;;
      "-u"|"--user"       ) user="$1"; shift ;;
      "-p"|"--pass"       ) pass="$1"; shift ;;
      *                   ) echo "ERROR: Invalid option: \""$opt"\"" >&2 ; exit 1 ;;
    esac
  done
fi

[[ -z "$fr" ]] && { echo "=> [Backup repository]  (-f|--from) cannot remain empty" >&2 ; exit 1 ; }
[[ -z "$to" ]] && { echo "=> [Storage repository] (-t|--to) cannot remain empty" >&2 ; exit 1 ; }

if [[ "$user" == "" || "$pass" == "" ]]; then
  echo "=> Username and Password for GIT are a requirement." >&2 ; exit 1
fi


## Unset usage from global scope
unset -f print_usage

echo "=> Temporary directory is: $tmpdir"

## Identify repository URL type...
if [[ $fr =~ ^http ]] ; then
  repository=$(echo $fr |awk -F 'com/' '{print$2}' |awk -F '.git' '{print$1}' |sed 's/\//\:/g')
elif [[ $fr =~ ^git ]] ; then
  repository=$(echo $fr |awk -F 'com:' '{print$2}' |awk -F '.git' '{print$1}' |sed 's/\//\:/g')
else
  echo '=> You fucked up' ; exit 1
fi

echo -e "=> Cloning: ${repository}"
cd /tmp && git clone --bare "$fr" $repository

echo -e '=> Compressing...'
tar -zcf "${repository}.tar.gz" $repository
git clone "$to" $tmpdir

if [ -f "$tmpdir/$repository.tar.gz" ] ; then
  echo '=> Cowardly refusing to overwrite existent file, exiting...' ; exit 1
fi

mv "${repository}.tar.gz" "$tmpdir/$repository.tar.gz"
cd $tmpdir ; git status ; git add -A . ; git commit -m "Cold storing: ${repository}" ; git push --force
rm -fr /tmp/{$tmpdir,$repository}

echo -e "=> Attempting to remove ${repository}"

# token=$(curl --silent -u "$user:$pass" -X POST https://api.github.com/authorizations \
# -d "{\"scopes\":[\"delete_repo\"], \"note\":\"token with delete repo scope $random\"}" 2>&1 | \
# grep '"token"' |awk -F ':' '{print$2}' |cut -d'"' -f2)
#
# echo "=> Token Bearer: $token"
# curl -X GET -H "'Authorization: token $token'" https://api.github.com/repos/

drop=$(echo $repository |sed 's/:/\//g')
org=$(echo $drop |awk -F '/' '{print$1}')
rep=$(echo $drop |awk -F '/' '{print$2}')

## Get URL to delete
url=$(curl --silent -u "$user:$pass" -X GET https://api.github.com/orgs/$org/repos \
|grep -i "$drop" |grep '"url"' |awk -F '":' '{print$2}' |cut -d'"' -f2)

curl -v -u "$user:$pass" -X DELETE "$url"
