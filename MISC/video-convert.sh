#!/bin/bash
function ConvertToMp4() {

  if [ "x$1" != "x" ] ; then
    [ -d "${1}" ] && {
      cd "${1}" ## changedir to specified directory
    } || {
      echo -e "[warn] Directory '${1}' does not exist, exiting..."
      exit 3
    }
  fi

  ## mkdtemp
  temp_dir=$(mktemp -d |awk '{print$1}')
  echo -e "[info] Temporary directory is: ${temp_dir}"

  for file in *.flv ; do
    local base_name=$(basename "${file}" .flv)
    local mp4_name="${base_name}.mp4"

    ## info stuff....
    echo -e "[info] Discovered: $file"
    echo -e "[info] Converting: ${base_name}"
    ffmpeg -i "$file" "${mp4_name}" #&>/dev/null

    mv "${file}" "${temp_dir}"
  done

  pushd "${temp_dir}"

    ## contents in sane manner
    ls -lAh --group-directories-first \
    |awk -v OFS='\t' '{print $1, $5, substr($0, index($0,$9))}'

  popd

  read -r -p "Remove temp directory and contents? [Y/n]: " resp
  resp=${resp,,} ## tolower

  ## housecleaning
  [[ $resp =~ ^(yes|y| ) ]] && rm -fr "$temp_dir"

}
ConvertToMp4 "$1"
