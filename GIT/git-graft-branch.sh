#!/bin/bash

from="$1"
b1="$2"

to="$3"
b2="$4"

[[ -z "$fr" ]] || [[ -z "$to" ]] || [[ -z "$b1" ]] || [[ -z "$b2" ]] && {
  echo "$0 [Repo From] -> [Branch 1] | [Repo To] -> [Branch 2]"
  exit 1
}

cd /tmp

echo -e '\nPulling...\n'
git clone --bare "$fr" from/
cd $from

echo -e '\nGrafting...\n'
git checkout "$b1" "remotes/$b1"

git push --mirror "$to"
rm -fr /tmp/from

echo -e '\nSuccess!!'
