#!/bin/bash

# references
# http://wiki.opscode.com/display/chef/Chef+Repository
# http://blog.ibd.com/howto/deploy-wordpress-to-amazon-ec2-micro-instance-with-opscode-chef/

read -p "Chef repository name: " chef-dir
read -p "Chef server:          " chef-server


# on laptop
sudo gem install chef
sudo gem install net-ssh net-ssh-multi highline fog
 
mkdir ~/Repositories
cd ~/Repositories
https://github.com/opscode/chef-repo.git $chef-dir
cd $chef-dir
rm -rf .git
mkdir site-cookbooks
echo "Directory for customized cookbooks" > site-cookbooks/README.md
cat <<EOF >> .gitignore
.chef
client-config
*~
.DS_Store
metadata.json
EOF
 
git init
git add .
git commit -m "Setup chef-repo"
git tag -a v0.1 -m "0.1 release"
 
mkdir ~/git/$(chef-dir)/.chef

# create client key on chef server; scp client key down to laptop; remove client key from chef server
knife client create $(whoami) -n -a -f /tmp/$(whoami).pem
scp -i ~/.ssh/chef_rsa ubuntu@$(chef-server):{.chef/validation.pem,/tmp/$(whoami).pem} ~/git/$(chef-dir)/.chef/
rm /tmp/$(whoami).pem
 
cat <<EOF > ~/git/$(chef-dir)/.chef/knife.rb
current_dir = File.dirname(__FILE__)
log_level :info
log_location STDOUT
cache_type 'BasicFile'
cache_options( :path => "#{current_dir}/checksums" )
cookbook_path ["#{current_dir}/../cookbooks", "#{current_dir}/../site-cookbooks"]
chef_server_url "$(chef-server)"
validation_client_name 'chef-validator'
validation_key "#{current_dir}/validation.pem"
node_name '$(whoami)'
client_key "#{current_dir}/$(whoami).pem"

# EC2
knife[:aws_access_key_id]     = "Your AWS Access Key"
knife[:aws_secret_access_key] = "Your AWS Secret Access Key"
EOF
chmod 600 ~/git/$(chef-dir)/.chef/{knife.rb,$(whoami).pem}
 
mkdir -p ~/.chef/$(chef-dir)
cat <<EOF > ~/.chef/$(chef-dir)/shef.rb
node_name '$(whoami)'
client_key File.expand_path('~/.chef/$(chef-dir)/$(whoami).pem')
chef_server_url "$(chef-server)"
EOF
ln -s ~/git/$(chef-dir)/.chef/$(whoami).pem ~/.chef/$(chef-dir)/
 
cd ~/git/$(chef-dir)
git checkout -b develop master
knife cookbook site vendor chef-client -d -B develop
knife cookbook site vendor runit -d -B develop
git branch -d chef-vendor-chef-client chef-vendor-runit
 
cat <<EOF > ~/git/$(chef-dir)/roles/base.rb
name "base"
description "Base role applied to all nodes"
override_attributes(
"chef_client" => {
"init_style" => "runit"
}
)
run_list(
"recipe[chef-client::delete_validation]",
"recipe[runit]",
"recipe[chef-client]"
)
EOF
 
cd ~/git/$(chef-dir)
rake roles
knife role list
knife cookbook upload -a
knife cookbook list
 
cd ~/git/$(chef-dir)
knife ec2 server create "role[base]" -i ami-3e02f257 -G default -x ubuntu -f m1.small -I ~/.ssh/chef_rsa -S chef-keypair
knife status --run-list
 
cd ~/git/$(chef-dir)
git add roles/base.rb
git commit -m "Create 'base' role for chef clients"
git checkout master
git merge --no-ff develop
git tag -a v0.2 -m "0.2 release"
git checkout develop