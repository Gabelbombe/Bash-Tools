#!/bin/bash
# Youtube to MP3 Bash Script

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2015-07-06 @ 09:44:54
# VER : Version 5 (OSX Darwin)

# REQ : http://developer.echonest.com/docs/v4/song.html

# no long-opts supported except --help
while getopts 'v:d:i:-:' OPT; do
  case $OPT in
    v) address=$OPTARG;;
    d) dir=$OPTARG;;
    i) image=$OPTARG ; eval image=$image;;
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
  # default to /home/{user}/Music
  address=$1; dir="/Users/${USER}/Music/"
}

regex='v=(.*)'

[[ $address =~ $regex ]] && {
  video_id=${BASH_REMATCH[1]}
  video_id=$(echo $video_id | cut -d'&' -f1)

  filename=$(basename "$FILEPATH")
  extension="${filename##*.}"

  # remove thumb if exists
  [ -f 'thumbnail.jpg' ] && {
    rm -f 'thumbnail.jpg'
  }

  # get/set thumbnail for MP3
  [ ! -f "${image}" ] && {
    youtube-dl --write-thumbnail $address -o thumbnail.jpg
  } || {
    cp -ir "${image}" thumbnail.jpg
  }

  video_title="$(youtube-dl --get-title $address |sed s/://g)"
  artist="$(echo $video_title |awk -F '-' '{print$1}' |sed -e 's/\[.*//g' -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/')"
  title="$(echo $video_title |awk -F '-' '{print$2}' |sed -e 's/\[.*//g' -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/')"

  # download the FLV stream
  youtube-dl -o "$video_title".flv $address

  ffmpeg -i "$video_title".flv         \
        -acodec libmp3lame             \
        -ab 320k                       \
        -ac 2                          \
        -vn                            \
        -y "$video_title".mp3

  # add image with LAME since FFMPEG changes too much....
  lame --preset insane -V0 --id3v2-only --ignore-tag-errors \
       --ti 'thumbnail.jpg'                                 \
       --ta "$artist"                                       \
       --tt "$title"                                        \
       --tv "TPE2=${artist}"                                \
       "$video_title".mp3 "${dir}/${video_title}.mp3"

  rm -f *.{webm,mp4,flv,mp3,jpg}
} || {
  echo "Sorry but you seemed to broken the interwebs."
}
