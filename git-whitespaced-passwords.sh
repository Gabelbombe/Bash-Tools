#!/bin/bash

## Get user creds and stuff    
read -p "Enter STASH Username: " user
read -p "Enter STASH Password: " pass

## Current repos as an array 
repos=( BenApp BenSrv BenShuttle )

## Push up the limit so we won't choke
git config --global http.postBuffer 2G

## pathectory to clone to, can be .
read -p "What is your clone path: " path

## Make 
[ -d "${path}" ] || { 
    mkdir -p "${path}" ;
}

## Go
cd "${path}"

## Do it
for i in "${repos[@]}"; do
    repo=$(echo "git clone 'https://${user}:${pass}@stash.corbis.com/scm/bnr/$(echo $i | awk '{print tolower($0)}').git' $i/")
    eval "$(echo $repo)"
done
