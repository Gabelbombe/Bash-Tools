#!/bin/bash

shopt -s extglob
for i in $( seq 1  5); do 

	[[ $i = 1 ]] || echo "1"
	[[ $i = 2 ]] || echo "2"
	[[ $i = 3 ]] || echo "3"
	[[ $i = [1-3]* ]] && echo "! $i"

echo -e "\n"

done


