#!/bin/bash
# Organize ROM files based on country codes
 
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-11-13 @ 20:49:01

# INP : $ ./reorg-roms.sh

dir='/home/ehime/Downloads/GBA ROMs'
cd "$dir"

for file in *; do

	[ ! -d "$file" ] && {

		name=$(echo "$file" |sed -e 's/^[0-9]*\s-\s//g')
		code=$(echo "$name" |perl -l -ne '/\(([A-Z]*)\)/ and print $1')


		## http://snesorama.us/board/showthread.php?8-What-the-letters-at-the-end-of-ROM-files-mean
		case "$code" in
			'A'  ) region='Australia' 		;;
			'C'	 ) region='China'			;;
			'E'  ) region='Europe'			;;
			'FN' ) region='Finland'			;;
			'F'	 ) region='France'			;;
			'GR' ) region='Greece'			;;
			'G'  ) region='Germany'			;;
			'HK' ) region='Hong Kong'		;;
			'I'	 ) region='Italy'			;;
			'J'  ) region='Japan' 			;;
			'K'	 ) region='Korea'			;;
			'NL' ) region='Dutch'			;;
			'PD' ) region='Public Domain'	;;
			'S'	 ) region='Spanish'			;;
			'SW' ) region='Sweden'			;;
			'UK' ) region='United Kingdom'	;;
			'U'  ) region='USA'				;;
			'UE' ) region='USA'				;;
			*	 ) region='Unkown'			;;
		esac

		[ -d "$region" ] || mkdir "$region"

		echo -e "Moving: $name\nRegion: $region\n"

		mv "$file" "$region/$name" 
	} || {
		echo -e "Hit a directory somehow?\n"
	}
done

echo "Done!!!"