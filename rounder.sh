#!/bin/bash

set -x

stamp='stamp.nfo'
query=$(mysql -u$1 -p$2 -sN -e "SELECT cron, addr FROM webarchiver.userlist")
array=( $( for i in $query ; do echo $i ; done ) ) #arr

for (( i=0 ; i<${#array[@]} ; i++ )); do 

	[ $((($i-1)%2)) -eq 0 ] && continue

	for i in $(seq 1 ${array[$i]}); do 
		if [ $((24/$i)) -eq $(date -r ${stamp} +%H) ]; then 

			touch -d "+$((24/4)) hour" ${stamp} 

				echo $ADDR >> data.csv
		fi
	done
done