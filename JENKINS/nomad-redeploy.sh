#!/bin/bash
declare -a NOMAD_REPOS
declare -r ACCESS_TOKEN='217db8283b0501ce53604d961ac920abb5a8de11'
declare -r DEPLOY_FNAME='deploy.tmpl.nomad'

TOKEN_USER="admin"
TOKEN="93fd4b480887851651c8d7c16762941b"
JH="http://localhost:8080"
PROJECT="Deploy%20Service"

echo -e "Querying for repositories with deploy.tmpl.nomad in path"

NOMAD_REPOS=($(curl -sSL -H "Accept: application/vnd.github.v3+json" \
"https://api.github.com/search/code?per_page=200&q=deploy.tmpl.nomad+in:path+org:d3sw&access_token=217db8283b0501ce53604d961ac920abb5a8de11" \
|jq -r '.items[].repository.name'))

echo "Listing forked repositories"
FORKED_REPOS=$(curl -sS -H "Accept: application/vnd.github.v3+json" "https://api.github.com/search/repositories?q=fork:only+org:d3sw&access_token=${ACCESS_TOKEN}" \
|jq -r '.items[].name')

echo "Merging forked repositories with deploy.tmpl.nomad in path"
for REPO in $FORKED_REPOS ; do
  [ 200 = $(curl -s -o /dev/null -w "%{http_code}" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/d3sw/${REPO}/contents/${DEPLOY_FNAME}?per_page=100&page=$page&access_token=${ACCESS_TOKEN}") ] && {
    echo -e "+ $REPO" ; NOMAD_REPOS+=($REPO)
  }
done

echo -e "Discovered: ${#NOMAD_REPOS[@]} repos"

for NAME in "${NOMAD_REPOS[@]}" ; do
  echo -e "Deploying: ${NAME}" ; echo curl --silent -X POST "${JH}/job/${PROJECT}/buildWithParameters?NAME=${NAME}&ENV_TYPE=${ENV_TYPE}&GIT_TAG=${GIT_TAG}" --user ${TOKEN_USER}:${TOKEN}
done
