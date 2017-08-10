#!/usr/bin/env bash
USERNAME='username'
PASSWORD='password'
ORGSNAME='organisation'
SSHBYPAS='-work'

ssh-add -l ; read -p "If your key is not present please add, otherwise type [n]: " load

[[ $load != n ]] && ssh-add $(eval echo $load)

mkdir -p ~/Repositories/${ORGSNAME} \
&& cd $_

for REPO in $(curl -sSL -u "${USERNAME}:${PASSWORD}" \
  https://api.github.com/orgs/${ORGSNAME}/repos      \
  |jq -r '.[] .ssh_url') ; do
    [[ $SSHBYPAS = *[![:space:]]* ]] && {
      REPO=$(echo $REPO |sed "s/github\.com/github\.com${SSHBYPAS}/")
    }
  git clone $REPO
done
