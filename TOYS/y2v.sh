#!/bin/bash
# Youtube to Video Bash Script

# CPR : Jd Daniel :: Gabelbombe
# MOD : 2013-22-07 @ 12:01:20
# VER : Version 3

# if short order (y2v http://addy.com)
if [ -e $address ]; then
    address=$1

    # default to /home/{user}/Music
    dir="/Users/${USER}/Movies/Y2V/"
fi

regex='v=(.*)'

if [[ $address =~ $regex ]]; then

    video_id=${BASH_REMATCH[1]}
    video_id=$(echo $video_id | cut -d'&' -f1)

  FILENAME=$(basename "$FILEPATH")
  EXTENSION="${FILENAME##*.}"

  if [ $video_id != "*" ]; then
    DATA=$(curl -s https://gdata.youtube.com/feeds/api/videos/$video_id?v=2)
    PUBLISHED=$(echo $DATA | php -r 'print simplexml_load_file("php://stdin")->published;' | sed 's/\..*Z/Z/')
    AUTHOR=$(echo $DATA | php -r 'print simplexml_load_file("php://stdin")->author->name;')
    TITLE=$(echo $DATA | php -r '$x = simplexml_load_file("php://stdin"); $ns = $x->getNameSpaces(true); $m = $x->children($ns["media"]); print $m->group->title;')
    DESCRIPTION=$(echo $DATA | php -r '$x = simplexml_load_file("php://stdin"); $ns = $x->getNameSpaces(true); $m = $x->children($ns["media"]); print $m->group->description;')
    COMMENT="http://www.youtube.com/watch?v=$YOUTUBE_ID"
    ALBUM=$AUTHOR

      if [ "$1" ]; then
        TITLE="$AUTHOR: $TITLE"
        AUTHOR=$1
        ALBUM=$1
      fi
  fi

    # adding thumbnail to the MP3
    youtube-dl --write-thumbnail $address -o thumbnail.jpg
    video_title="$(youtube-dl --get-title $address)"

    author="$(echo $video_title |awk -NF '-' '{print$1}' |sed -e 's/\[.*//g' -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/')"
    title="$(echo $video_title |awk -NF '-' '{print$2}' |sed -e 's/\[.*//g' -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/')"

        # download the FLV stream
        youtube-dl -o "$video_title".flv $address

    ffmpeg -i "$video_title".flv          \
           -i "thumbnail.jpg"             \
           -metadata author="$author"     \
           -metadata title="$title"       \
           -qscale 0                      \
           -ar 22050                      \
           -vcodec libx264                \
           -y "$video_title".mp4

        # untested
       if [ -z "$dir" ]; then
         if [[ ! -d $dir ]]; then
           echo "Creating directory $dir"
           echo mkdir -p $dir
         fi
       fi

    cp "$video_title".mp4 $dir

    rm -f "$video_title".flv "thumbnail.jpg"
else
    echo "Sorry but you seemed to broken the interwebs."
fi
