#!/bin/bash

# REF : https://github.com/lericson/git-remote-deploy
# helper script to set up the remote and deploy hook
# usage: setup-repo [deploy url]
# execute from the root of repository

SRC="$0/../src"
GIT_DIR="$(git rev-parse --git-dir)"

NAME="deploy"
URL="$1"
if [ -z "$URL" ]; then
    echo "Specify remote url for deploy, e.g."
    echo "  foo@myserver:/usr/local/myproject"
    read -p "Remote: " URL
    [ -n "$URL" ] || exit
    echo
    echo "$URL needs to be a Git repository with a work tree."
    echo "If you haven't created it already, you can do that now."
    echo
    read -p "Press Enter to continue"
    echo
fi

"$SRC/setup-remote" "$NAME" "$URL"
echo
echo -e "\x1b[32\x6dAll set up!\x1b[0\x6d Try it:"
echo "  git push $NAME"
