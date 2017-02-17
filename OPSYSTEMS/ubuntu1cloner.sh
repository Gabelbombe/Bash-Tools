#!/bin/bash
# Cloning tool that will move all your synced Ubuntu One music to your real music folder
# Folder MUST exist first otherwise it will be ignored, will rename your track cuz U1 is dumb

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2013-11-09 @ 17:02:54
# VER : Version 1

cd ~/.ubuntuone/Purchased\ from\ Ubuntu\ One/

find . -type f -name "*.mp3" -printf '%P\0' |
    while read -d $'\0' path; do
        DIRNAME=$(dirname "$path")
        MP3FILE=$(basename "$path")

        # get the directory to move too
		MOVE=${DIRNAME##*/}
		NAME=${DIRNAME%/*}

		if [ -d "~/Music/${MOVE}" ]; then
			cp "$path" "~/Music/$MOVE/$NAME - $MP3FILE"
		fi
    done
