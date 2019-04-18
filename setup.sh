#!/bin/bash
# CPR : Jd Daniel :: Ehime-ken
# VER : 1.0
#

## Update Brew
brew update


## NIX your env
brew reinstall coreutils
brew reinstall binutils
brew reinstall diffutils
brew reinstall ed         --with-default-names
brew reinstall findutils  --with-default-names
brew reinstall gawk
brew reinstall gnu-indent --with-default-names
brew reinstall gnu-sed    --with-default-names
brew reinstall gnu-tar    --with-default-names
brew reinstall gnu-which  --with-default-names
brew reinstall gnutls     --with-default-names
brew reinstall grep       --with-default-names
brew reinstall gzip
brew reinstall tmux
brew reinstall screen
brew reinstall watch
brew reinstall wdiff      --with-gettext
brew reinstall wget       --with-debug --with-gpgme --with-pcre
brew reinstall expect
brew reinstall ncurses
brew reinstall gpg
brew reinstall htop


## Network
brew reinstall netcat
brew reinstall nmap --with-pygtk
brew reinstall rsync
brew reinstall wireshark  \
  --with-headers        \
  --with-libsmi         \
  --with-libssh         \
  --with-nghttp2        \
  --with-qt


## Fresher bins
brew reinstall bash
brew reinstall emacs
brew reinstall gdb      # gdb requires further actions to make it work. See `brew info gdb`.
brew reinstall gpatch
brew reinstall m4
brew reinstall make     --with-default-names
brew reinstall cmake    --with-completion
brew reinstall nano


## Cloud `things`
# HashiCorp
brew reinstall consul                         \
             consul-template                \
             fabio

brew reinstall nomad

brew reinstall packer                         \
             packer-completion

brew reinstall serf

brew reinstall terraform                      \
             terraform-docs                 \
             terragrunt                     \
             terraform-provisioner-ansible  \
             terraform-inventory            \
             terraforming                   \

brew reinstall vault

brew reinstall kubernetes-cli

# Amazon Web Services
brew reinstall awscli
brew reinstall awslogs
brew reinstall aws-cfn-tools

# Azure
brew reinstall azure-cli


## Cask reinstall VirtualBox and Vagrant
echo "-- reinstalling Cloud Casks"
brew cask reinstall virtualbox

brew cask reinstall vagrant
brew reinstall vagrant-completion

brew cask reinstall google-cloud-sdk
echo -e "
## Autocompletion settings for Google Cloud
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'
" >> ~/.bashrc


## Add trusted certs
#security import /tmp/MyCertificates.p12 -k $HOME /Library/Keychains/login.keychain -P -T /usr/bin/codesign
