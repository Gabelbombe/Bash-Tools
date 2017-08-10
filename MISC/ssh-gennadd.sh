#!/usr/bin/env bash -e
function genpass ()
{
    LEN=${1:-32} ; pwgen -syBv -1 $LEN |head -c -1 |pbcopy
    echo -e '[info] Random pass generated and copied..'
}

declare -r bldPass=$(genpass)
declare -r pubFile=~/.ssh/build_rsa

ssh-keygen -o         \
  -a 100              \
  -b 4096             \
  -t ed25519          \
  -N "${bldPass}"     \
  -f "${pubFile}"

chmod 0600 "${pubFile}*"

  pubKey=$(<"$pubFile.pub")

eval "$(ssh-agent -s)"

  ssh-add "${pubFile}"
