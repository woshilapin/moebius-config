#!/bin/bash

CUR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $CUR_PATH/functions.sh

cd $HOME

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
