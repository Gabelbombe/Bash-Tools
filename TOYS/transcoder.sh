#!/bin/bash
# Video transcoder
#
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-02-24 @ 16:34:29
# VER : Beta 3

inp="drop"
out="export"
clear # set -x

## test for reqs of exit
for requires in ffmpeg parallel; do
    hash $requires 2>/dev/null || {
        echo >&2 "I require $requires to run but it's not installed.  Aborting."; exit 1;
    }
done

## dectypes
declare -r fpath=$( cd "$(dirname "$0")" ; pwd -P )
declare -r types="asf\|asx\|avi\|flv\|m4v\|mkv\|mov\|mp4\|mpg\|ogg\|rm\|swf\|vob\|webm\|wmv"
declare -r allow=( mp4 ogg webm )
##

    for dir in "$inp" "$out"; do
        [ -d "$fpath/$dir" ] || { mkdir -p "$fpath/$dir"; } # create if not available
    done

    [ -z "$(ls $fpath/$inp)" ] && { "$fpath is empty, finished..."; exit 0; } # exit when empty


    ## start video conversion
    cd $fpath ; while IFS= read -r video; do

        skip=0 #reset skip flag
        name="${video%.*}"
        exts="${video##*.}"

        # assign predetermined pos
        for (( i = 0; i < ${#allow[@]}; i++ )); do
           if [ "${allow[$i]}" = "${exts}" ]; then
               skip=$(($i + 1));
           fi
        done


        pids=() # pid track if we want to use it later for something
        [[ $skip = 1 ]] || { ffmpeg -y -i "$inp/$video" -vb 1500k -vcodec libx264 -vpre slow -vpre baseline -g 30 "$out/${name}.mp4" 2> /dev/null & } # \n pid+="$! " # if we're going to do post proc kill work later
        [[ $skip = 2 ]] || { ffmpeg -y -i "$inp/$video" -vb 1500k -vcodec libvpx -acodec libvorbis -ab 160000 -f webm -g 30 "$out/${name}.webm" 2> /dev/null & }
        [[ $skip = 3 ]] || { ffmpeg -y -i "$inp/$video" -vb 1500k -vcodec libtheora -acodec libvorbis -ab 160000 -g 30 "$out/${name}.ogg" 2> /dev/null & }


        # move out of path
        for ext in "${allow[@]}"; do
            [ -a "$inp/$name.$ext" ] && cp -f "$inp/$name.$ext" "$out/" &
        done

        for job in `jobs -p`; do
            echo "Job: $job"
            wait $job || let "FAIL+=1"
        done

        [ "0" == "$FAIL" ] && echo "YAY!" || echo "FAIL! ($FAIL)"

    done <<< $(find "$fpath/$inp" -type f -iregex ".*\(${types}\)" -printf '%P\0 ')