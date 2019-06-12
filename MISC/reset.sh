#!/bin/bash

working=$(pwd)


cd /tmp
ssh git@localhost 'drop erado.com'
rm -rf /home/jdaniel/www/arcserver.dev
git clone git@github.com:Gabelbombe/arc-server.git /home/jdaniel/www/arcserver.dev

sleep 5
cd /home/jdaniel/www/arcserver.dev/scripts
echo 'erado.com' > 'test.nfo'