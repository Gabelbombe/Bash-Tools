#!/usr/local/bin/bash
# ORG File search script

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2018-03-26 @ 13:14:54
# REF : goo.gl/eSMM17
# VER : Version 1.0.0

# REQ : Bash 4.3+
# 2694750e6c88b974add0a377d6fa3fac990d1fb3

################################################################################
################################################################################

GUD=()
BAD=()

for remote in $(cat files/owf-live.txt) ; do

  git ls-remote git@github.com:d3sw/$remote 2>&1 |head -n1 |grep 'ERROR' 1>/dev/null
  [ 1 = $? ] && {

    ID=$(curl --silent -u "ehime:" -H "Authorization: token 2694750e6c88b974add0a377d6fa3fac990d1fb3" -X GET https://api.github.com/orgs/d3sw/teams |jq --arg team "$remote" ".[] | select(.name==\"$remote\") | .id")
echo "$remote $ID"
  } || {
    BAD+=($remote)
  }
done

# echo 'Exists'
# echo ${GUD[@]}
#
# echo -e "\n\n"
#
# echo 'Missing'
# echo ${BAD[@]}

curl -u "ehime:" -H "Authorization: token 2694750e6c88b974add0a377d6fa3fac990d1fb3" \
-H "Accept: application/vnd.github.v3+json" \
"https://api.github.com/search/code?per_page=200&q=deploy.tmpl.nomad+in:path+org:d3sw+fork:true&access_token=217db8283b0501ce53604d961ac920abb5a8de11"

curl -sSL -H "Accept: application/vnd.github.v3+json" \
"https://api.github.com/search/code?per_page=200&q=deploy.tmpl.nomad+in:path+org:d3sw&access_token=217db8283b0501ce53604d961ac920abb5a8de11" \
|jq '.items[].repository.name'
