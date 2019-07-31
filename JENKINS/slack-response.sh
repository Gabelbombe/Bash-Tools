#!/bin/bash

TOKEN_USER="admin"
TOKEN="93fd4b480887851651c8d7c16762941b"
JH="http://localhost:8080"
PROJECT="Create%20Project"

allowed=" todd.schilling rampal ed shuoyen.lin Jd lukasz.margiela Max Golionko roman.belyakovsky.con "

if ! [[ $allowed =~ $user_name ]]; then
  exit 0;
fi

user_info=$(curl -X POST --data "token=xoxp-3645231051-11920467778-295838215735-736b890547980d625a5665359880f4c7&user=$user_id" https://slack.com/api/users.info)
name=$(echo $user_info | jq -r '.user.profile.real_name')
text="Please send a request to \`devops-support@bydeluxe.com\`."
data="{'username': 'Todd Schilling', 'text': '${text}'}"
curl -X POST -H "Content-Type:application/json" --data "${data}" ${response_url}
