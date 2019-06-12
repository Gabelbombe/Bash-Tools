#!/bin/bash -x
# Youtube to MP3 BASH script to steal shit...

CPR='Jd Daniel :: Gabelbombe'
MOD="$(date +'%Y-%m-%d @ %H:%M:%S')"
VER='7.1.0'

# REF : https://github.com/Gabelbombe/Bash-Tools/blob/master/TOYS/y2m.sh
# REQ : https://github.com/aadsm/JavaScript-ID3-Reader

##  Buyers beware....
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##


declare debug=''
declare title=''
declare isurl='http?(s)://*'

function print_usage()
{
  echo -e '
  Parameter usage: y2m [--help] [--title=<song-title>] [--video=<youtube-url>] [--cover=<cover-${save}>] [--save=<save-location>]
  Parameters:
    -t  --title   Title of the MP3 you want, should conform to `Art - Song Name`
    -v  --video   Video URL to fetch from YouTube
    -c  --cover   ${save} to attach to the MP3 [ Defaults to YouTube Promo ${save} ]
    -d  --save    Directory save location    [ Defaults to `~/Music` ]
    -v  --version Displays current version of y2m

    Advanced Parameters:
        --debug   Appends `sketchy debugging` to the script, trust it like youd trust a white girl...
        --update  Force updates `youtube-dl`, if you err out, run this...
        --flush   Flushes `youtube-dl` caches

  Example usage:
    Long:  y2m -t "Rick Astley - Never Gonna Give You Up" -s /dev/null -v http://www.youtube.com/watch?v=oHg5SJYRHA0‎"
    Short: y2m http://www.youtube.com/watch?v=oHg5SJYRHA0‎ ## just pirate the fucking thing already...
  '
}

## following requires modern GNU bash 3.2 you loser....
if (shopt -s nocasematch ; [[ ${1} = @(-h|--help) ]]) ; then
  print_usage ; return 1

## because you're a lazy cunt...
elif [[ [[ "${1}" =~ $isurl ]] ; then
  title="${1}"

else
  while [[ $# -gt 0 ]]; do
    opt="${1}" ; shift ;

    ## no one likes a smart-ass....
    current_arg="${1}"

    if [[ "${current_arg}" =~ ^-{0,1}.* ]] ; then
      echo -e "[fatal] The Universe doesn't give a fuck about your feelings..."
    fi

    case "${opt}" in
      "-t"|"--title"      ) title="${1}" ; shift ;;
      "-v"|"--video"      ) video="${1}" ; shift ;;
      "-c"|"--cover"      ) ${save}="${1}" ; shift ;;
      "-s"|"--save"       ) save="${1}"  ; shift ;;

      ## version out...
      "-v"|"--version"    ) echo -e "[info] Current verion is ${VER}"
                            return 1
                          ;;

      ## advanced flags, buyer beware...
      "--debug"           ) echo -e "[warn] Activating sketchy dumping..."
                            debug='--verbose --print-traffic --dump-pages'
                            shift
                          ;;

      "--flush"           ) echo -e "[info] Flushing caches..."
                            youtube-dl --no-check-certificate --rm-cache-dir
                            return 1

      "--update"          ) echo -e "[info] Force updating youtube-dl..."
                            sudo youtube-dl -U
                            return 1


      ## you sir, just boiled the fuckin ocean..
      *                   ) echo -e "[fatal] Invalid option: \""$opt"\"" >&2
                            return 6
                          ;;
    esac
  done
fi

## unset usage from global scope
unset -f print_usage


## make a temporary directory and move into it....
tmp_dir=$(mktemp -d -t y2m-XXXXXXXXXX) \
  && cd "${tmp_dir}"

echo -e "[info] Temporary directory is: ${tmp_dir}"


## TODO: implement for stripping / quoting
function ere_quote () {
  sed 's/[]\.|$(){}?+*^]/\\&/g' <<< "$*"
}

## if short order (y2m http://addy.com)
[ "x${video}" == "x" ] && { video=${1} ; }
[ "x${save}"  == "x" ] && { save="/Users/${USER}/Music/" ; }

## save location exists?
[ ! -d "${save}" ]     && {
  echo -e "[fatal] Directory '${save}' does not not exist..."
  return 9
}

## set comments
declare COMMENTS="
[CPR] ${CPR}
[MOD] ${MOD}
[VER] ${VER}
[REF] ${video}
"


echo -e "[info] Using directory: ${save}"

regex='v=(.*)'
[[ "${video}" =~ $regex ]] && {

  ## argsmap
  video_id="${BASH_REMATCH[1]}"
  video_id="$(echo $video_id| cut -d'&' -f1)"
  filename=$(basename "${FILEPATH}")
  extension="${filename##*.}"


  ## remove thumb if exists
  [ -f 'thumbnail.jpg' ] && {
    rm -f 'thumbnail.jpg'
  }


  ## get/set thumbnail for MP3
  if [[ "x${save}" == "x" && ! -f "${save}" ]] ; then
    echo -e "[info] Downloading thumbnail"
    youtube-dl --no-check-certificate "${debug}" --no-warnings --write-thumbnail "${video}" -o thumbnail.jpg
  else
    echo -e "[info] Using ${save} as thumbail"
    cp -ri "${save}" thumbnail.jpg
  fi


  ## if you haven't defined a title....
  [ "x${title}" == "x" ] && {
    title="$(youtube-dl --no-check-certificate "${debug}" --no-warnings --get-title "${video}" |sed s/://g)"
  }

  echo -e "[info] Title is: ${title}"


  # download the FLV stream
  youtube-dl --no-check-certificate "${debug}" --no-warnings -o "${title}" "${video}"

  artist="$(echo ${title} |awk -F ' - ' '{print${1}' |sed -e 's/\[.*//g' -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/')"
  title="$(echo ${title}  |awk -F ' - ' '{print$2}' |sed -e 's/\[.*//g' -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/')"


  ## format independant, might need: head -n1, also hates ( ) [ ] etc
  video=$(ls |grep "${artist}")

  echo -e "[info] Using Video: ${video}"

  ## REQ: FFMPEG proper installers via
  ## https://github.com/Gabelbombe/Bash-Tools/tree/master/STANDUP
  ffmpeg -i "$video"                   \
        -acodec libmp3lame             \
        -ab 320k                       \
        -ac 2                          \
        -vn                            \
        -y "${title}".mp3


  ## add ${save} with LAME since FFMPEG changes too much....
  lame --preset insane -V0 --id3v2-only --ignore-tag-errors \
       --ti 'thumbnail.jpg'                                 \
       --ta "${artist}"                                     \
       --tt "${title}"                                      \
       --tv "TPE2=${artist}"                                \
       --tc "${COMMENTS}"                                   \
   "${title}".mp3 "${save}/${title}.mp3"


  rm -f "${tmp_dir}" ## oikology...
} || {
  echo -e "[fatal] The Universe doesn't give a fuck about your feelings..."
}
