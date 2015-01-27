#!/bin/bash

name="${1}"
email="${2}"

## Rewrite history by name
git filter-branch --commit-filter "
if [ '$GIT_AUTHOR_NAME' != '$name' ]; then
  GIT_AUTHOR_NAME='$name'
  GIT_AUTHOR_EMAIL=$email
  GIT_COMMITTER_NAME='$name'
  GIT_COMMITTER_EMAIL=$email
fi
git commit-tree '$@'"
