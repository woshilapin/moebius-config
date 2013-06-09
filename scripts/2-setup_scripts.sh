#!/bin/bash

# Exit if any command fail
set -e

set +o xtrace
ROOT_PATH=$( cd -P -- "$(dirname -- "$0")" && pwd -P )
source $ROOT_PATH/functions.sh

SCRIPTS_PATH="$ROOT_PATH"
SCRIPTS_REMOTE_PATH="$ROOT_PATH/../remote_scripts"
REMOTE_ROOT_PATH="/root"
REMOTE_SCRIPTS_PATH="$REMOTE_ROOT_PATH/scripts"

print_info "Transfer installation scripts (password: raspi)"
scp -r $SCRIPTS_REMOTE_PATH root@tuziwo.no-ip.org:$REMOTE_SCRIPTS_PATH

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
print_info "you should run the scripts in '/root/scripts/'"
print_info "on your raspberry to finalize the configuration"
print_info ""
print_info "Press <ENTER> to finish"
print_info ""
read
