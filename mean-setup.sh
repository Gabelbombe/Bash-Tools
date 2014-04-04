#!/bin/bash
# CPR : Jd Daniel :: Ehime-ken
# MOD : 2014-04-02 @ 15:52:10
# VER : 1.1b

## ROOT check
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as su" 1>&2 ; exit 1
fi

####################################
####################################
###        Mongo DB Setup        ###
####################################
####################################

    ## Add the keyserv to list of realm items
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

    ## Create a /etc/apt/sources.list.d/mongodb.list file using the following command.
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

    ## UP
    sudo apt-get update

    ## Install req'd packages
    apt-get install -y mongodb-10gen=2.4.6

    ## Pin packages
    echo "mongodb-10gen hold" | sudo dpkg --set-selections

    ## Run it 
    if [ 'mongodb' == $(service --status-all 2>1 |grep 'mongodb' |awk '{print $4}') ]; then
        service mongodb restart
    fi

    ## Create base data path for mongod
    [ -d '/data/db' ] || mkpath -p /data/db

    ## Test mongod
    if [ ! -z "$(mongod 2>1 |grep -i 'error')" ]; then
        echo -e "\n\tError with mongod: $(mongod 2>1 |grep -i 'error')"
        exit 666
    fi


####################################
####################################
###        Node/NPM Setup        ###
####################################
####################################

    ## Install the node package
    apt-get install -y nodejs 

    ## Link into binaries as node
    ln -s /usr/bin/nodejs /usr/bin/node

    curl https://npmjs.org/install.sh | sudo sh

    echo -e "Node version is $(node --version)"

    ## Install NPM package manager
    cd /tmp && curl -O -L https://npmjs.org/install.sh

    ## Install
    sh install.sh

    echo -e "NPM version is $(npm --version)"

    ## Oikology
    rm -f install.sh


####################################
####################################
###     YO/Grunt/Bower Setup     ###
####################################
####################################

    ## Install precursers
    sudo apt-get install -y build-essential openssl libssl-dev curl

    [ ! -z "$(which git)" ] || apt-get install -y git git-core

    ## Get Node Version Manager
    git clone git://github.com/creationix/nvm.git ~/.nvm

    ## Add NVM to the ewnvironments scope
    echo '[[ -s "$HOME/.nvm/nvm.sh" ]] && source "$HOME/.nvm/nvm.sh"' >> ~/.bash_profile 

    ## Load NVM pathectly
    . ~/.nvm/nvm.sh

    echo -e "NVM version is $(nvm --version)"


    ## Install Yeoman to the global scope
    npm install -g yo


####################################
####################################
###      Repositories Setup      ###
####################################
####################################

    ## cont?
    read -p "Have repos to clone? [Y/n]: " repo


        ## stop... in the naaaame of.... wait... what the fuck....
        [ 'y' == "$(echo $repo | awk '{print tolower($0)}')" ] || exit 1


    read -p "What's the server [Aka: foo.com/somerepo]: " server

    ## broke the internet
    [ ! -z "$(ping -c 1 -q ${server} 2>&1 |grep 'unknown')" ] || {
        echo 'Uh... no.' ;
        exit 1 ;
    }

    ## Get user creds and stuff    
    read -p "Enter STASH Username: " user
    read -p "Enter STASH Password: " pass

    ## Current repos as an array 
    repos=( BenApp BenSrv BenShuttle )

    ## Push up the limit so we won't choke
    git config --global http.postBuffer 2G

    ## pathectory to clone to, can be .
    read -p "What is your clone path: " path

    ## Make 
    [ -d "${path}" ] || { 
        mkdir -p "${path}" ;
    }

    ## Go
    cd "${path}"

    ## Do it
    for i in "${repos[@]}"; do
        repo=$(echo "git clone 'https://${user}:${pass}@${server}/$(echo $i | awk '{print tolower($0)}').git' $i/")
        eval "$(echo $repo)"
    done