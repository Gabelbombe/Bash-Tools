#!/bin/bash

name="${1}"
email="${2}"

## Rewrite history by name
git filter-branch -f --env-filter "
    GIT_AUTHOR_NAME='$name'
    GIT_AUTHOR_EMAIL='$email'
    GIT_COMMITTER_NAME='$name'
    GIT_COMMITTER_EMAIL='$email'
" HEAD
