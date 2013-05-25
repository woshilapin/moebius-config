#!/bin/bash

# Exit if any command fail
set -e

set +o xtrace
CURRENT_PATH=`pwd`
ROOT_PATH=$( cd -P -- "$(dirname -- "$0")" && pwd -P )
IMG_PATH="$ROOT_PATH/img"
SCRIPTS_PATH="$ROOT_PATH/scripts"
SCRIPTS_REMOTE_PATH="$ROOT_PATH/remote_scripts"
UNZIP_PATH="$ROOT_PATH/unzip"
REMOTE_ROOT_PATH="/root"
REMOTE_SCRIPTS_PATH="$REMOTE_ROOT_PATH/scripts"

source $SCRIPTS_PATH/functions.sh

print_info ""
print_info "Setup the SD card"
print_info ""
source $SCRIPTS_PATH/1-setup_sd.sh

print_info ""
print_info "Setup the SSH connection"
print_info ""
source $SCRIPTS_PATH/2-setup_ssh.sh

print_info "Transfer SSH keys"
scp -r ~/.ssh/woshilapin* root@tuziwo.no-ip.org:/root/.ssh/

print_info "Transfer installation scripts"
scp -r $SCRIPTS_REMOTE_PATH root@tuziwo.no-ip.org:$REMOTE_SCRIPTS_PATH
ssh root@tuziwo.no-ip.org \
	"ln -s $REMOTE_SCRIPTS_PATH/0-setup.sh $REMOTE_ROOT_PATH/setup.sh"

print_info ""
print_info "Now go on raspberry with"
print_info "$> ssh root@tuziwo.no-ip.org"
print_info ""
print_info "The first run will lead you through basic configuration"
print_info "You just need to run 'AutoResize'"
print_info "'Password', 'Keyboard', 'Locale' and 'TimeZone' will be"
print_info "configure in following steps"
print_info ""
print_info "Once the SD card has been resized"
print_info "you should run the script '/root/setup.sh'"
print_info "on your raspberry to finalize the configuration"
print_info ""
print_info "Press <ENTER> to finish"
print_info ""
read

### Clean
cd $CURRENT_PATH
rm -Rf $UNZIP_PATH
