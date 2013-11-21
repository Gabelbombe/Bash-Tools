#!/bin/bash

# If the user is not root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2 ; exit 1
fi

cd /home/git/web-archive && rm -rf *

shopt -s dotglob
cd /home/jdaniel/www/arcserver.dev && rm -rf *
shopt -u dotglob 

git clone git@github.com:ehime/arc-server.git /home/jdaniel/www/arcserver.dev

chown -R jdaniel:jdaniel /home/jdaniel/www/arcserver.dev

cd /home/jdaniel/www/arcserver.dev/scripts
echo 'erado.com' > 'test.nfo'