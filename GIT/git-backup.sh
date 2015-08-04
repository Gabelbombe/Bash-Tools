#!/bin/bash
# ORG backup script

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-08-04 @ 10:29:06
# REF :
# VER : Version 1.0.0-dev

fr="$1"
to="$2"
repository=''
readonly tmpdir="/tmp/$(date |md5sum |awk '{print$1}')"
[[ -z "$fr" ]] && { echo "=> [Backup repository] cannot remain empty"  ; exit 1 ; }
[[ -z "$to" ]] && { echo "=> [Storage repository] cannot remain empty" ; exit 1 ; }

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
cd $tmpdir ; git status ; git add -A . ; git commit -m "Cold storing: ${repository}" ; git push
rm -fr /tmp/{$tmpdir,$repository}

echo -e '\nSuccess!!'
