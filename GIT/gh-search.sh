#!/usr/local/bin/bash
# ORG File search script

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2018-03-26 @ 13:14:54
# REF : goo.gl/eSMM17
# VER : Version 1.0.5

# REQ : Bash 4.3+

################################################################################
################################################################################


declare -i  incrm=1   ## as increment
declare     repos=''


function print_usage()
{
  echo -e '
  Parameter usage: git-backup.sh [--help] [--token=<mfa-token>] [--org=<git-organisation>] [--user=<github-username>] [--pass=<github-password>] [--file=<filename>] [--term=<keyword-match>]

  Parameters:
  -o  --org   Github organisation conencting to
  -f  --file  File to locate in repositories
  -t  --term  Search term to match in file
  -u  --user  Github username for API connection
  -p  --pass  Github password for API connection
  -m  --mfa   Github MFA token if used/required

  Example usage:
  gh-search.sh -u ehime -p "secure pass/token" --mfa 000000 \
    --org github                                            \
    --file README\.md                                       \
    --term "GNU Public License"
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
      "-f"|"--file"       ) file="$1" ; shift   ;;
      "-t"|"--term"       ) term="$1" ; shift   ;;

      # File and Term need to be included
      *                   ) echo "ERROR: Invalid option: \""$opt"\"" >&2 ; exit 1 ;;
    esac
  done
fi

## gewaltenteilung
[[ -z "$org" ]]   && { echo "=> [GitHub Organization]  (-o|--org) cannot remain empty"  >&2 ; exit 1 ; }
[[ -z "$file" ]]  && { echo "=> [GitHub File]          (-f|--file) cannot remain empty" >&2 ; exit 1 ; }
[[ -z "$term" ]]  && { echo "=> [Search Term]          (-t|--term) cannot remain empty" >&2 ; exit 1 ; }


## Unset usage from global scope
unset -f print_usage

CURL="curl --silent -u \"$user:$pass\""

[ "${mfa}z" != "z" ] && {
  CURL="$CURL -H \"Authorization: token ${mfa}\""
}


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

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')
cd $tmpdir

  echo "Created: ${tmpdir} for operations.."


## cycling through capture list
for repo in ${repos} ; do
  name="$(echo ${repo} |sed -e 's:.*/::' -e 's/\.[^.]*$//')"
  echo -e "Process: [$((decr--))/${total}] ${name}"

  git clone -q $repo \
  && cd "${name}"

  SEARCH="find . -type f -name \"${file}\""
  [ "${term}x" = '*x' ] && {
    SEARCH='find . -type f |grep -v "\.git/"'
  }

  ## does it even exist?
  capture='' ; capture=$(eval $SEARCH)
  [ "${capture}z" != 'z' ] && {

      IFS=' ' read -r -a files <<< "$capture"
      for name in "${files[@]}" ; do
        echo -e "\tLocated: ${name}"
        grep -n -Ii "${term}" $(echo $name |sed -e 's/..//')
      done

    echo -e '' ## gimme some space
  }

  cd $tmpdir && rm -fr "${name}"
done

rm -fr "$tmpdir"
