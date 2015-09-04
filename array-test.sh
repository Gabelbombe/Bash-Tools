#!/bin/bash -eux
# Does array spacing matter?
declare -a array1=(foo bar baz)
declare -a array2=(
  foo
  bar
  baz
)

echo Using array: ${array1[@]}
for a in ${array1[@]} ; do
  echo $a
done

echo -e "\n"

echo Using array: ${array2[@]}
for a in ${array2[@]} ; do
  echo $a
done
