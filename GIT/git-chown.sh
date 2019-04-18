#!/bin/bash
function chown()
{
  ## Rewrite history by name
  echo -e "\nRewriting ownership history..."

  git filter-branch -f --env-filter "
    GIT_AUTHOR_NAME='$1'
    GIT_AUTHOR_EMAIL='$2'
    GIT_COMMITTER_NAME='$1'
    GIT_COMMITTER_EMAIL='$2'
  " HEAD
  git push -f ; echo
}

function sign()
{
  # Rewrite history and Sign all commits
  echo -e "\nRewriting signers history..."

  git filter-branch -f --commit-filter '
    git commit-tree -S "$@";
  ' HEAD
  git push -f ; echo
}

for tag in $(git tag |awk '{print$1}') ; do
  echo -e "\nOperating on: $tag"
  chown "$1" "$2"
  sign
done

# Now do master...
echo -e " \nChowning 'Master' branch.."
chown "$1" "$2"
sign
