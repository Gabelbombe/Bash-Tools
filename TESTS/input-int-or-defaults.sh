#!/bin/bash
declare -ri INT=${1:-42}
[ 0 = $INT ] && {
  echo -e '[err] failcode passed, ARG_1 was either string or nullable...' ; exit 1
}
echo -e "[info] Integer is: ${INT}..."
