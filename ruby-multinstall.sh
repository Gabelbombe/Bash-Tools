#!/bin/bash
#
# Installs following on Ubuntu 13.10:
# -> Ruby 2.0 
# -> RubyGems 2.1.11
# -> Rails (stable)
# -> SASS
# -> Compass

#sudo apt-get update && sudo apt-get install -y build-essential git git-core curl openjdk-7-jdk sqlite3 libsqlite3-dev libxml2-dev libxslt1-dev libreadline-dev libyaml-dev libcurl4-openssl-dev libncurses5-dev libgdbm-dev libffi-dev

cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/ruby-2.0.0-p247.tar.gz
tar xvzf ruby-2.0.0-p247.tar.gz
cd ruby-2.0.0-p247
./configure
make
sudo make install

cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-2.1.11.tgz
tar xvzf rubygems-2.1.11.tgz
cd rubygems-2.1.11
sudo ruby setup.rb
sudo gem update --system

echo -e "Ruby version is $(ruby --version)"
echo -e "GEM version is  $(gem  --version)"

sudo gem install rails rake rawr sass compass