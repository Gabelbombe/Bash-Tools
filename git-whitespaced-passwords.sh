#!/bin/bash

    read -p "Enter STASH Username: " user
    read -p "Enter STASH Password: " pass

    repos=( BenApp BenSrv BenShuttle )

	git config --global http.postBuffer 2G

    for i in "${repos[@]}"; do
	    repo=$(echo "git clone 'https://${user}:${pass}@stash.corbis.com/scm/bnr/$(echo $i | awk '{print tolower($0)}').git' $i/")
	    eval "$(echo $repo)"
    done


