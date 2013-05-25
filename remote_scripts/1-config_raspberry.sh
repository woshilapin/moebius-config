#!/bin/bash

source $SCRIPTS_PATH/functions.sh

print_info "Change the root password"
if test `whoami` = 'root'
then
	passwd
else
	print_err "This script should be executed with root privileges"
fi

print_info "Create the new 'woshilapin' user"
useradd \
	--base-dir /home \
	--comment "woshilapin" \
	--home-dir /home/woshilapin \
	--create-home \
	--shell /bin/zsh \
	--user-group \
	woshilapin
print_info "Change the password for 'woshilapin' user"
passwd woshilapin

### Configure the system
print_info "Configure the locales"
dpkg-reconfigure locales

print_info "Configure the timezone"
dpkg-reconfigure tzdata

print_info "Configure the keyboard (fr)"
sed -i 's/^XKBLAYOUT.*$/XKBLAYOUT="fr"/' /etc/default/keyboard &&
invoke-rc.d keyboard-setup start

print_info "Change the name of the system"
print_info "The modification will be update on next reboot"
HOSTNAME=`cat /etc/hostname`
echo 'tuziwo' > /etc/hostname
sed -i 's/'$HOSTNAME'/tuziwo/g' /etc/hosts

### Update the system
print_info "Update the package tree"
yes | apt-get update
print_info "Upgrade the system"
yes | apt-get upgrade
