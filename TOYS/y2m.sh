#!/bin/bash
# Youtube to MP3 Bash Script
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-12-05 @ 10:54:55
# VER : Version 4 (OSX Darwin)

# no long-opts supported except --help
while getopts 'v:d:-:' OPT; do
  case $OPT in
    v) address=$OPTARG;;
    d) dir=$OPTARG;;
    -) #long option
       case $OPTARG in

         help) echo 'Long:  y2m -d {directory} -v {ex: http://www.youtube.com/watch?v=oHg5SJYRHA0‎}'
           echo 'Short: y2m {ex: http://www.youtube.com/watch?v=oHg5SJYRHA0‎}'
           exit;;

       esac;;
  esac
done

cd /tmp

# if short order (y2m http://addy.com)
if [ -e $address ]; then
    address=$1

    # default to /home/{user}/Music
    dir="/Users/${USER}/Music/"
fi

regex='v=(.*)'

if [[ $address =~ $regex ]]; then

    video_id=${BASH_REMATCH[1]}
    video_id=$(echo $video_id | cut -d'&' -f1)

  FILENAME=$(basename "$FILEPATH")
  EXTENSION="${FILENAME##*.}"

  if [ $video_id != "*" ]
  then
    DATA=`curl -s https://gdata.youtube.com/feeds/api/videos/$video_id?v=2`
    PUBLISHED=`echo $DATA | php -r 'print simplexml_load_file("php://stdin")->published;' | sed 's/\..*Z/Z/'`
    AUTHOR=`echo $DATA | php -r 'print simplexml_load_file("php://stdin")->author->name;'`
    TITLE=`echo $DATA | php -r '$x = simplexml_load_file("php://stdin"); $ns = $x->getNameSpaces(true); $m = $x->children($ns["media"]); print $m->group->title;'`
    DESCRIPTION=`echo $DATA | php -r '$x = simplexml_load_file("php://stdin"); $ns = $x->getNameSpaces(true); $m = $x->children($ns["media"]); print $m->group->description;'`
    COMMENT="http://www.youtube.com/watch?v=$YOUTUBE_ID"
    ALBUM=$AUTHOR

    if [ "$1" ]
    then
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
           -acodec libmp3lame             \
           -ac 2                          \
           -ab 320k                       \
           -vn                            \
           -y "$video_title".mp3

        # untested
       if [ -z "$dir" ]; then
         if [[ ! -d $dir ]]; then
           echo "Creating directory $dir"
           echo mkdir -p $dir
         fi
       fi

    cp "$video_title".mp3 $dir

    rm -f "$video_title".flv "$video_title".mp3 "thumbnail.jpg" *.{webm,mp4}
else
    echo "Sorry but you seemed to broken the interwebs."
fi
