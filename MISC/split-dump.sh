#!/usr/bin/env bash

# When executing the script keep the main db dump in another folder.
declare REGEX_NAME="Current Database: \`(.*)\`"

# Checks argument and prints usage if needed
[ "$#" -lt "1" ] && {
  echo -e "Usage: ${0} <dump.sql>" ; exit 1
}

# Splits dump into temporary files
/usr/bin/awk '/Current Database\: .*/{g++} { print $0 > g".tmpsql" }' "${1}"

# Renames files or appends to existing one (to handle views)
for f in *.tmpsql ; do
  DATABASE_LINE=$(head -n1 "${f}")

  [[ $DATABASE_LINE =~ $REGEX_NAME ]] && {
    TARGET_FILE=${BASH_REMATCH[1]}.sql
  }

  [ -f "${TARGET_FILE}" ] && {
    cat "${f}" >> ${TARGET_FILE} ; rm -f "${f}"
  } || {
    mv "${f}" ${BASH_REMATCH[1]}.sql
  }
done
