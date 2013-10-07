#!/bin/bash
stamp='stamp.nfo'
query=$(mysql -u$1 -p$2 -sN -e "SELECT cron, addr FROM webarchiver.userlist")
array=( $( for i in $query ; do echo $i ; done ) ) #arr

clear; set -x # debug

# echo -e "Elements:\n"; printf -- '- %s\n' "${array[@]}"; echo
for (( i=0 ; i<${#array[@]} ; i++ )); do 

	[ $((($i-1)%2)) -eq 0 ] && continue

	sepr=${array[$i]}
	addr=${array[$i-1]}
	for i in $(seq 1 ${array[$i]}); do 

		# +'%-' will elmitnate leading zeros
		if [ $((24/$i)) -eq $(date -r ${stamp} +%-H) ]; then 

			ttime=$((24/$sepr)) + $(date -r ${stamp} +%-H)

			touch -d "+${ttime} hour" ${stamp} 

			echo "Added ${addr}....\n"
			echo "${addr}" >> data.csv

		fi
	done
done