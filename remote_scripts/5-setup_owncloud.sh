#!/bin/bash

set +o xtrace
CURRENT_PATH=`pwd`
DL_PATH="$HOME/downloads"

mkdir $DL_PATH

function program_exit {
	apt-get autoremove
	rm -Rf $DL_PATH
	cd $CURRENT_PATH
}

function print_err {
	echo "`basename $0`: error: $1"
	program_exit
}

function print_info {
	echo "---> $1"
}

### Install ownCloud
print_info "Installing apache2"
yes "Y" | apt-get install apache2 apache2-doc
print_info "Installing php5"
yes "Y" | apt-get install php5 php5-json php5-sqlite php5-curl php5-zip php5-gd
print_info "Installing additionnal php packages"
yes "Y" | apt-get install php-xml php-mbstring php-pdo
print_info "Installing curl"
yes "Y" | apt-get install curl libcurl3 libcurl3-dev
print_info "Installing owncloud (for the dependencies)"
yes "Y" | apt-get install owncloud
print_info "Downloading owncloud"
cd $DL_PATH && \
	wget http://mirrors.owncloud.org/releases/owncloud-4.5.1.tar.bz2
print_info "Downloading owncloud checksum"
cd $DL_PATH && \
	wget http://mirrors.owncloud.org/releases/owncloud-4.5.1.tar.bz2.md5
print_info "Checking owncloud"
cd $DL_PATH && \
	md5sum owncloud-4.5.1.tar.bz2
print_info "Uncompressing owncloud"
cd /var/www/ && \
	tar xvjf $DL_PATH/owncloud-4.5.1.tar.bz2
print_info "Initializing owncloud"
chown -R www-data:www-data /var/www/owncloud/

### Clean
program_exit
