#!/bin/bash

# Exit if any command fail
set -e

set +o xtrace
CURRENT_PATH=`pwd`
ROOT_PATH=/root
SCRIPTS_PATH="$ROOT_PATH/scripts"

source $SCRIPTS_PATH/functions.sh

print_info "Initial configuration of the raspberry"
source $SCRIPTS_PATH/1-config_raspberry.sh

print_info "Install basics programs"
source $SCRIPTS_PATH/2-setup_base.sh

print_info "Configuration for root user"
ssh-agent source $SCRIPTS_PATH/3-config_root.sh

print_info "Copy SSH keys to 'woshilapin'"
cp -R /root/.ssh/ /home/woshilapin/.ssh
chown -R woshilapin:woshilapin /home/woshilapin/.ssh

print_info "Copy script files to 'woshilapin'"
cp -R /root/scripts/ /home/woshilapin/scripts
chown -R woshilapin:woshilapin /home/woshilapin/scripts

print_info "Configuration for woshilapin user"
touch /home/woshilapin/.zshrc
chown woshilapin:woshilapin /home/woshilapin/.zshrc
su - woshilapin \
	--command "ssh-agent source /home/woshilapin/scripts/4-config_woshilapin.sh"

print_info "You can now backup your system"
print_info "You can also run moebius.config to resize your partition"

### Clean
cd $CURRENT_PATH
rm -Rf $UNZIP_PATH
