#!/bin/bash

type="${1}"

if [] ## nope

        ## Rewrite history by name
        git filter-branch --commit-filter '
        if [ "$GIT_COMMITTER_NAME" = "ehime" ];
        then
                GIT_COMMITTER_NAME="Jd Daniel";
                GIT_AUTHOR_NAME="Jd Daniel";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' HEAD
else
        ## Drop commit by name
        git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_NAME" = "ehime" ];
        then
            skip_commit "$@";
        else
            git commit-tree "$@";
        fi' HEAD
fi