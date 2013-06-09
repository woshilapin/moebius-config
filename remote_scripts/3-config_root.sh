#!/bin/bash

# Exit if any command fail
set -e

set +o xtrace
ROOT_PATH=$( cd -P -- "$(dirname -- "$0")" && pwd -P )
source $ROOT_PATH/functions.sh

cd $HOME

### Configure basic programs
print_info "Download configuration files (read-only)"
git clone git://github.com/woshilapin/dot.git ~/.dot
cd ~/.dot && git submodule init
cd ~/.dot && git submodule update
cd ~/.dot && bash update.sh

print_info "Change default shell to zsh"
echo "/bin/zsh" | chsh

exit
