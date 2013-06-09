#!/bin/bash

# Exit if any command fail
set -e

set +o xtrace
ROOT_PATH=$( cd -P -- "$(dirname -- "$0")" && pwd -P )
source $ROOT_PATH/functions.sh

cd $HOME

ERR_MSG=""
if [ `whoami` != 'woshilapin' ]
then
	print_info "You must be 'woshilapin' user to execute this script"
	ERR_MSG="You are not 'woshilapin' user."
fi
if [ -z $SSH_AGENT_PID ]
then
	print_info "You must run a SSH agent for this script."
	print_info "$> ssh-agent 'bash "$0"'"
	ERR_MSG="No SSH agent found."
fi
if [ \! -f ~/.ssh/woshilapin@gmail.com.rsa ]
then
	print_info "You must upload 'woshilapin' SSH keys on 'tuziwo'"
	print_info "Put 'woshilapin' SSH keys in '/home/woshilapin/.ssh'"
	ERR_MSG="No 'woshilapin' SSH key found."
fi
if [ -z $ERR_MSG ]
then
	print_info ""
	print_info "To run this script, you should try the following:"
	print_info "First copy '"$0"' and 'functions.sh' in '/home/woshilapin/'"
	print_info "Then change owner of these files to 'woshilapin'"
	print_info "Change user to 'woshilapin'"
	print_info "Open a shell with an SSH agent"
	print_info "Finally, run the script"
	print_info ""
	print_info "#> cp {"$0",functions.sh} /home/woshilapin/"
	print_info "#> chown woshilapin:woshilapin /home/woshilapin/*.sh"
	print_info "#> su woshilapin"
	print_info "$> ssh-agent 'bash'"
	print_info "$> bash '"$0"'"
	print_info ""
	print_err $ERR_MSG
fi

### Add ssh keys
print_info "Add SSH private key to the agent"
ssh-add ~/.ssh/woshilapin@gmail.com.rsa

### Configure basic programs
print_info "Download configuration files"
git clone git@github.com:woshilapin/dot.git ~/.dot
cd ~/.dot && git submodule init
cd ~/.dot && git submodule update
rm -f ~/.zshrc
cd ~/.dot && bash update.sh
cd ~/.dot && echo '[user]' >> .git/config
cd ~/.dot && echo -e '\tname = "woshilapin"' >> .git/config
cd ~/.dot && echo -e '\temail = "woshilapin@gmail.com"' >> .git/config

print_info "Change default shell to zsh"
echo "/bin/zsh" | chsh

exit
