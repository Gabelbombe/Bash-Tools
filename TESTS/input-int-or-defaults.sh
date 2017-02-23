#!/bin/bash

declare -ri INT=${1:-32}
[ 0 = $INT ] && {
  echo -e '[err] failcode passed, ARG1 was either string or nullable...' ; exit 1
}

echo -e "[info] Integer is: ${INT}..."
