#!/bin/bash

# Exit if any command fail
set -e

set +o xtrace
ROOT_PATH=$( cd -P -- "$(dirname -- "$0")" && pwd -P )
source $ROOT_PATH/functions.sh

cd $HOME

if [ -z $SSH_AGENT_PID ]
then
	print_info "You must run a SSH agent for this script."
	print_info "$> ssh-agent 'bash "$0"'"
	print_err "No SSH agent found."
fi
if [ \! -f ~/.ssh/woshilapin@gmail.com.rsa ]
then
	print_info "You must upload 'woshilapin' SSH keys on 'tuziwo'"
	print_info "Put 'woshilapin' SSH keys in '/home/woshilapin/.ssh'"
	print_err "No 'woshilapin' SSH key found."
fi

### Add ssh keys
print_info "Add SSH private key to the agent"
ssh-add ~/.ssh/woshilapin@gmail.com.rsa

### Configure basic programs
print_info "Download configuration files"
git clone git@github.com:woshilapin/dot.git ~/.dot
cd ~/.dot && git submodule init
cd ~/.dot && git submodule update
rm ~/.zshrc
cd ~/.dot && bash update.sh
cd ~/.dot && echo '[user]' >> .git/config
cd ~/.dot && echo -e '\tname = "woshilapin"' >> .git/config
cd ~/.dot && echo -e '\temail = "woshilapin@gmail.com"' >> .git/config

exit
