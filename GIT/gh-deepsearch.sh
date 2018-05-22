#!/usr/local/bin/bash
# ORG Deep file search script

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2018-03-26 @ 13:14:54
# VER : Version 1.0.0

# USE : ./gh-deepsearch.sh -u $GH_USER -o d3sw -m $GH_TOKEN -f 'deploy.tmpl.nomad' -r 'value.*=.*test.'
# REQ : Bash 4.3+

################################################################################
################################################################################


declare REPOS=''

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir')
function ctrl_c() {
  echo "** Trapped abort, cleaning up.."
  rm -fr "${tmpdir}"
}

function print_usage()
{
  echo -e '
  Parameter usage: gh-deepsearch.sh [--help] [--token=<mfa-token>] [--org=<git-organisation>] [--user=<github-username>] [--pass=<github-password>] [--file=<filename>] [--term=<keyword-match>]

  Parameters:
  -o  --org     Github organisation conencting to
  -f  --file    File to locate in repositories
  -r  --regexp  Search term to match in file
  -u  --user    Github username for API connection
  -m  --mfa     Github MFA token if used/required

  Example usage:
  gh-search.sh -u ehime -p "secure pass/token" --mfa 000000 \
    --org    github                                         \
    --file   deploy\.tmpl\.nomad                            \
    --regexp "value.*=.*test."
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
      "-o"|"--org"        ) org="$1"    ; shift   ;;
      "-u"|"--user"       ) user="$1"   ; shift   ;;
      "-m"|"--mfa"        ) mfa="$1"    ; shift   ;;
      "-f"|"--file"       ) file="$1"   ; shift   ;;
      "-r"|"--regxp"      ) regexp="$1" ; shift   ;;

      # File and Term need to be included
      *                   ) echo "ERROR: Invalid option: \""$opt"\"" >&2 ; exit 1 ;;
    esac
  done
fi

## gewaltenteilung
[[ -z "$org" ]]     && { echo "=> [GitHub Organization]  (-o|--org) cannot remain empty"  >&2 ; exit 1 ; }
[[ -z "$regexp" ]]  && { echo "=> [Search Regexp]        (-r|--regexp) cannot remain empty" >&2 ; exit 1 ; }

## Unset usage from global scope
unset -f print_usage

CURL="curl --silent -u \"$user:$pass\" -H \"Accept: application/vnd.github.v3+json\""
[ "${mfa}z" != "z" ] && {
  CURL="$CURL -H \"Authorization: token ${mfa}\""
}


TOTAL=$(eval $CURL --data-urlencode "'q=org:${org} in:path ${file}'" \
-G https://api.github.com/search/code |jq '.total_count')

echo -e "[info] Querying for repositories with ${file} in path"
for ITER in $(seq 1 $(($TOTAL/100+1))) ; do

  for REPO in $(eval $CURL --data-urlencode "'q=org:${org} in:path ${file}'"  \
    --data-urlencode "'per_page=100'"                                         \
    --data-urlencode "'page=${ITER}'"                                         \
    -G https://api.github.com/search/code |jq -r '.items[].repository.name') ; do

    REPOS+=($REPO) ##will de-dupe so you'll get a diff # than total

  done
done

echo -e '[info] Searching forked repositories'
FORKS=$(eval $CURL --data-urlencode "'q=fork:only org:${org}'"  \
-G https://api.github.com/search/repositories                   \
|jq -r '.items[].name')

echo -e "[info] Merging forked repositories with ${file} in path"
for REPO in $FORKS ; do
  HTTP_CODE=$(eval $CURL                      \
              --output         /dev/null      \
              --write-out      "%{http_code}" \
              -G https://api.github.com/repos/${org}/${REPO}/contents/${file})

  [ 200 = $HTTP_CODE ] && {
    echo -e "+ $REPO" ; REPOS+=($REPO)
  }
  unset HTTP_CODE
done


UNIQ=($(echo "${REPOS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
TOTAL=${#UNIQ[@]}
DECRM=${#UNIQ[@]}


cd "$tmpdir" ; echo "[info] Created: ${tmpdir} for operations.."


## cycling through capture list
for REPO in ${UNIQ[@]} ; do
  NAME=$(echo "${REPO}" |sed -e 's:.*/::' -e 's/\.[^.]*$//')
  echo -e "Process: [$((DECRM--))/${TOTAL}] ${NAME}"

  git clone -q "git@github.com:${org}/${REPO}.git" \
  && cd "${NAME}"

  # GIT GREP Search for matches
  git grep -ne "${regexp}" $(git ls-remote . 'refs/remotes/*' |cut -f2) \
    |awk -F'[/|:]' '{
      print"+ Found in branch: " $4
    }' |sort -u

    cd $tmpdir \
    && rm -fr "${NAME}"

  [ 1 = DECRM ] && break
done

  rm -fr "$tmpdir"

trap EXIT
