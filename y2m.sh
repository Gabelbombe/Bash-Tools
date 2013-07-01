#!/bin/bash
# Youtube to MP3 Bash Script

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-25-06 @ 10:45:38

# Ubuntu
# REQ : sudo apt-get install youtube-dl && youtube-dl -U
# REQ : sudo apt-get install lame
# REQ : ./getffmpegproper || ffmpeg [use: http://pastebin.com/iYGwzQGw]

 
# Fedora (18) / Arch
# REQ : sudo yum -y install youtube-dl && sudo youtube-dl -U
# REQ : sudo yum -y install lame
# REQ : ./getffmpegproper-arch || ffmpeg [use: http://pastebin.com/jVzaaHgb]

 
address=$1
regex='v=(.*)'
if [[ $address =~ $regex ]]; then
        video_id=${BASH_REMATCH[1]}
        video_id=$(echo $video_id | cut -d'&' -f1)
        video_title="$(youtube-dl --get-title $address)"
        youtube-dl -o "$video_title".flv $address
        ffmpeg -i "$video_title".flv -acodec libmp3lame -ac 2 -ab 256k -vn -y "$video_title".mp3
        mv "$video_title".mp3 ~/Music
        rm "$video_title".flv
else
        echo "Sorry but you seemed to broken the interwebs."
fi