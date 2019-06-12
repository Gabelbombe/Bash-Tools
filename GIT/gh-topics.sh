#!/usr/local/bin/bash
# ORG Topics search script

# CPR : Jd Daniel :: Gabelbombe
# MOD : 2018-03-26 @ 16:28:55
# REF : goo.gl/FQCHNP
# VER : Version 1.0.1

# REQ : Bash 4.3+

################################################################################
################################################################################


declare -i  incrm=1   ## as increment
declare     repos=''


function print_usage()
{
  echo -e '
  Parameter usage: git-backup.sh [--help] [--token=<mfa-token>] [--org=<git-organisation>] [--user=<github-username>] [--pass=<github-password>]  [--term=<keyword-match>]

  Parameters:
  -o  --org   Github organisation conencting to
  -u  --user  Github username for API connection
  -p  --pass  Github password for API connection
  -m  --mfa   Github MFA token if used/required
  -t  --term  Search term to match in file

  Example usage:
  gh-search.sh -u Gabelbombe -p "secure pass/token"  \
    --mfa 000000                                \
    --org github                                \
    --term platform
  '
}

## Following requires modern GNU bash 3.2 WILL FAIL....
if (shopt -s nocasematch; [[ $1 = @(-h|--help) ]]); then
  print_usage ; exit 1
else
  while [[ $# -gt 0 ]]; do
    opt="$1" ; shift ;
    current_arg="$1"
    if [[ "$current_arg" =~ ^-{1,2}.* ]]; then
      echo "=> You may have left an argument blank. Double check your command."
    fi
    case "$opt" in
      "-o"|"--org"        ) org="$1"  ; shift   ;;
      "-u"|"--user"       ) user="$1" ; shift   ;;
      "-p"|"--pass"       ) pass="$1" ; shift   ;;
      "-m"|"--mfa"        ) mfa="$1"  ; shift   ;;
      "-t"|"--term"       ) term="$1" ; shift   ;;

      # File and Term need to be included
      *                   ) echo "ERROR: Invalid option: \""$opt"\"" >&2 ; exit 1 ;;
    esac
  done
fi

## gewaltenteilung
[[ -z "$org" ]]   && { echo "=> [GitHub Organization]  (-o|--org) cannot remain empty"  >&2 ; exit 1 ; }


## Unset usage from global scope
unset -f print_usage

CURL="curl --silent -u \"$user:$pass\" -H \"Accept: application/vnd.github.mercy-preview+json\""

[ "${mfa}z" != "z" ] && {
  CURL="$CURL -H \"Authorization: token ${mfa}\""
}

#echo -e "CMD is: ${CURL}"
while true ; do
  test="$(eval $CURL -X GET https://api.github.com/orgs/$org/repos?page=$incrm |jq -r '.[] .ssh_url')"

    [ "${test}z" != "z" ] || break

  ## does not respect \n
  repos="${repos}
${test}" ; test=''
  echo -e "Adding $org repositories page: $((incrm++))"
done

echo ; unset incrm ## clean

  ## set count && decr
  total=$(echo "${repos}" |wc -l) ; decr=$total

echo >| output.log ## nuke n' pave

## cycling through capture list
for repo in ${repos} ; do
  name="$(echo ${repo} |sed -e 's:.*/::' -e 's/\.[^.]*$//')"

    echo -e "Process: [$((decr--))/${total}] ${name}"

  output=$(eval $CURL -X GET "https://api.github.com/repos/$org/$name/topics")
  query="jq '.names | contains([\"$term\"])'"

  [ 'true' == $(echo $output |eval $query) ] && {
    echo $output |sed -e "s/names/$name/"
    echo $name   >> output.log
  }

done
