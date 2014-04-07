#!/bin/bash
# Youtube to MP3 Bash Script
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-22-07 @ 12:01:20
# VER : Version 3

# Ubuntu
# REQ : sudo apt-get install youtube-dl && youtube-dl -U
# REQ : sudo apt-get install lame
# REQ : ./getffmpegproper || ffmpeg [use: http://pastebin.com/iYGwzQGw]


# Fedora (18) / Arch
# REQ : sudo yum -y install youtube-dl && sudo youtube-dl -U
# REQ : sudo yum -y install lame 
# REQ : su -c "curl http://download.opensuse.org/repositories/home:/satya164:/fedorautils/Fedora_18/home:satya164:fedorautils.repo -o /etc/yum.repos.d/fedorautils.repo && yum install fedorautils"
# REQ : su -c 'yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-18.noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-18.noarch.rpm'
# REQ : sudo yum -y install gstreamer gstreamer-ffmpeg gstreamer-plugins-bad gstreamer-plugins-bad-free gstreamer-plugins-bad-nonfree gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-ugly ffmpeg yasm yasm-devel

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
    dir="/home/${USER}/Music/"
fi

regex='v=(.*)'

if [[ $address =~ $regex ]]; then

    video_id=${BASH_REMATCH[1]}
    video_id=$(echo $video_id | cut -d'&' -f1)

    # adding thumbnail to the MP3
    thumb="$(youtube-dl --write-thumbnail $address |grep "to:.*" |awk '{for(i=6;i<=NF;i++) printf $i" "}' |cut -d'.' --complement -f2-)"

    rm -f "$thumb".{webm,mp4} # not needed for thumbstamp

    video_title="$(youtube-dl --get-title $address)"

        # download the FLV stream
        youtube-dl -o "$video_title".flv $address

    ffmpeg -i "$video_title".flv -i "$thumb".jpg -acodec libmp3lame -ac 2 -ab 320k -vn -y "$video_title".mp3

        # untested
       if [ -z "$dir" ]; then
         if [[ ! -d $dir ]]; then
           echo "Creating directory $dir"
           echo mkdir -p $dir
         fi
       fi

    mv "$video_title".mp3 $dir
    rm "$video_title".flv "$thumb".jpg
else
    echo "Sorry but you seemed to broken the interwebs."
fi
