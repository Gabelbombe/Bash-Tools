#!/bin/bash

fr="$1"
to="$2"

[[ -z "$fr" ]] || [[ -z "$to" ]] && {
  echo "$0 [Repo From] [Repo To]"
  exit 1
}

echo -e '\n[info] Pulling...\n'
cd /tmp && git clone --bare     "$fr" from/

echo -e '\n[info] Pushing...\n'
cd from && git push  --mirror   "$to"
rm -fr /tmp/from

echo -e '\n[info] Success!!'
