#!/bin/bash
# Youtube to MP3 Bash Script

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-01-08 @ 16:31:02
# VER : Version 5 (OSX Darwin)

# no long-opts supported except --help
while getopts 'v:d:-:' OPT; do
  case $OPT in
    v) address=$OPTARG;;
    d) dir=$OPTARG;;
    -) #long option
    case $OPTARG in

      help) echo 'Long:  y2m -d {directory} -v {ex: http://www.youtube.com/watch?v=oHg5SJYRHA0‎}'
      echo 'Short: y2m {ex: http://www.youtube.com/watch?v=oHg5SJYRHA0‎}'
      exit
      ;;

    esac;;
  esac
done

cd /tmp

# if short order (y2m http://addy.com)
[ -e $address ] && {
  address=$1

  # default to /home/{user}/Music
  dir="/Users/${USER}/Music/"
}

regex='v=(.*)'

[[ $address =~ $regex ]] && {
  video_id=${BASH_REMATCH[1]}
  video_id=$(echo $video_id | cut -d'&' -f1)

  filename=$(basename "$FILEPATH")
  extension="${filename##*.}"

  # get thumbnail for MP3
  youtube-dl --write-thumbnail $address -o thumbnail.jpg
  video_title="$(youtube-dl --get-title $address)"

  artist="$(echo $video_title |awk -NF '-' '{print$1}' |sed -e 's/\[.*//g' -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/')"
  title="$(echo $video_title |awk -NF '-' '{print$2}' |sed -e 's/\[.*//g' -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/')"

  # download the FLV stream
  youtube-dl -o "$video_title".flv $address

  ffmpeg -i "$video_title".flv         \
        -acodec libmp3lame             \
        -ac 2                          \
        -ab 320k                       \
        -vn                            \
        -y "$video_title".mp3

  # add image with LAME since FFMPEG changes too much....
  lame --preset insane -V0 --id3v2-only --ignore-tag-errors  \
        --ti thumbnail.jpg                                   \
        --ta "$artist"                                       \
        --tt "$title"                                        \
        --tv "TPE2=${artist}"                                \
        "$video_title".mp3 "${dir}/${video_title}.mp3"


  rm -f "$video_title".flv thumbnail.jpg *.{webm,mp4}
} || {
  echo "Sorry but you seemed to broken the interwebs."
}
