#!/bin/bash
# http://www.arthur-training.com/Downloads/forensics/

declare -r base_url="${1%/}" ## remove trailing slash

echo >| /tmp/whitelist
echo >| /tmp/blacklist
echo >| /tmp/fetchlist

function encode() { python -c "import urllib; print urllib.quote('''$1''')" ; }
function decode() { python -c "import urllib; print urllib.unquote_plus('''$1''')" ; }
function gather()
{
  while IFS=$'\n' read line ; do
    line=$(echo $line |sed 's/[:blank:]+/%20/g')
#    line=$(python -c "import urllib; print urllib.quote('''$line''')")
    echo -e "$line"
  done < <(wget -qO- "${1}" |awk -F$'\n' 'BEGIN{
  RS="</a>"
  IGNORECASE=1
  } {
    for(o=1;o<=NF;o++){
      if ( $o ~ /href/){
        gsub(/.*href=\042/,"",$o)
        gsub(/\042.*/,"",$o)
        print $(o)
      }
    }
  }' |grep -v '^/\|^?')
}

uniq=($(printf "%s\n" "$(gather ${base_url})" |sort -u))
for line in  "${uniq[@]}" ; do
  if [ ! -z $(echo $line |grep -i \.pdf) ] ; then
    echo -e "${base_url}/${line}" >> /tmp/fetchlist
  else
    path="$(decode "${base_url}/${line}" |sed 's/\&amp;/\&/g')"
    if ! grep "$path" /tmp/blacklist ; then
      echo $path >> /tmp/whitelist
      echo -e "Added $path"
    fi
  fi
done
