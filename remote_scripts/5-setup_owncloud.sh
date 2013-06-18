#!/bin/bash

# Exit if any command fail
set -e

set +o xtrace
ROOT_PATH=$( cd -P -- "$(dirname -- "$0")" && pwd -P )
source $ROOT_PATH/functions.sh


set +o xtrace
RESOURCES_PATH=$ROOT_PATH/resources
DL_PATH="$HOME/downloads"
SRV_PATH=/srv
WWW_PATH=$SRV_PATH/www
SSL_PATH=$SRV_PATH/ssl
SSL_CERTS_PATH=$SSL_PATH/certs
SSL_NEWCERTS_PATH=$SSL_PATH/newcerts
SSL_CRL_PATH=$SSL_PATH/crl
SSL_PRIVATE_PATH=$SSL_PATH/private
SSL_REQ_PATH=$SSL_PATH/req

mkdir -p $DL_PATH
mkdir -p $WWW_PATH
mkdir -p $SRV_PATH
mkdir -p $SSL_PATH

### Install ownCloud
print_info "Installing apache2"
yes "Y" | apt-get install apache2 apache2-doc
print_info "Installing php5"
yes "Y" | apt-get install php5
print_info "Installing sqlite-php packages"
yes "Y" | apt-get install php5-sqlite
print_info "Installing additionnal php packages"
yes "Y" | apt-get install php5-gd php-xml-parser php5-intl smbclient
print_info "Installing curl"
yes "Y" | apt-get install curl libcurl3 php5-curl
print_info "Downloading owncloud"
cd $DL_PATH && \
	wget http://download.owncloud.org/community/owncloud-5.0.7.tar.bz2
print_info "Downloading owncloud checksum"
cd $DL_PATH && \
	wget http://download.owncloud.org/community/owncloud-5.0.7.tar.bz2.md5
print_info "Checking MD5"
cd $DL_PATH && \
	md5sum owncloud-5.0.7.tar.bz2
print_info "Uncompressing owncloud"
cd $WWW_PATH && \
	tar xvjf $DL_PATH/owncloud-5.0.7.tar.bz2
print_info "Initializing owncloud"
chown -R www-data:www-data $WWW_PATH/owncloud/

print_info "Initialize SSL directories"
mkdir -p $SSL_PATH
mkdir -p $SSL_CERTS_PATH
mkdir -p $SSL_NEWCERTS_PATH
mkdir -p $SSL_CRL_PATH
mkdir -p $SSL_PRIVATE_PATH
mkdir -p $SSL_REQ_PATH
echo 01 > $SSL_PATH/serial
touch $SSL_PATH/index.txt
SSL_CNF_FILE=$SSL_PATH/openssl.cnf
cp $RESOURCES_PATH/openssl.cnf $SSL_CNF_FILE
print_info "Create a private key (enter a strong password) as a CA*"
print_info ""
print_info "* CA: Certificate Authority"
SSL_CA_PRIVATE_KEY_FILE=$SSL_PRIVATE_PATH/cakey.pem
openssl genrsa \
	-des3 \
	-out $SSL_CA_PRIVATE_KEY_FILE \
	4096
print_info "Create a signed certificate as a CA*"
print_info "Use the previous password to unlock the key"
print_info "and keep default information"
print_info ""
print_info "* CA: Certificate Authority"
SSL_CA_CERT_FILE=$SSL_CERTS_PATH/cacert.pem
openssl req \
	-config $SSL_CNF_FILE \
	-new \
	-x509 \
	-nodes \
	-sha1 \
	-days 1 \
	-key $SSL_CA_PRIVATE_KEY_FILE \
	-out $SSL_CA_CERT_FILE
mkdir -p $SSL_PATH/$FQDN_NAME
print_info "Create a private key (enter a strong password)"
FQDN_NAME=tuziwo
SSL_PRIVATE_KEY_FILE=$SSL_PRIVATE_PATH/PATH/$FQDN_NAME.key.pem
openssl genrsa \
	-des3 \
	-out $SSL_PRIVATE_KEY_FILE \
	4096
print_info "Create a certificate"
print_info "Use the previous password to unlock the key"
print_info "and keep default information (even for 'challenge password' and"
print_info "'optional company name')"
SSL_CSR_FILE=$SSL_REQ_PATH/$FQDN_NAME.csr.pem
openssl req \
	-config $SSL_CNF_FILE \
	-new \
	-key $SSL_PRIVATE_KEY_FILE \
	-out $SSL_CSR_FILE
print_info "Sign the certificate"
SSL_CERT_FILE=$SSL_CERTS_PATH/$FQDN_NAME.cert.pem
yes | openssl ca \
	-config $SSL_CNF_FILE \
	-policy policy_anything \
	-out $SSL_CERT_FILE \
	-infiles $SSL_CSR_FILE
print_info "Create a no-key private key (from private key)"
SSL_PRIVATE_KEY_NOPASS_FILE=`echo $SSL_PRIVATE_KEY_FILE |
	sed 's/\.key/\.key\.nopass/'`
openssl rsa \
	-in $SSL_PRIVATE_KEY_FILE \
	-out $SSL_PRIVATE_KEY_NOPASS_FILE

print_info "Configure Apache with certificates"
print_info "Configure SSL on Apache"
IS_LISTEN=`sed '/<IfModule mod_ssl\.c>/,/<\/IfModule>/ s/Listen 443/XXXXX/g' ports.conf | grep 'XXXXX' | wc -l`
if [ $IS_LISTEN -eq 0 ]
then
	echo '<IfModule mod_ssl.c>' >> /etc/apache2/ports.conf
	echo '\tListen 443' >> /etc/apache2/ports.conf
	echo '\tNameVirtualHost *:443' >> /etc/apache2/ports.conf
	echo '</IfModule>' >> /etc/apache2/ports.conf
else
IS_LISTEN=`sed '/<IfModule mod_ssl\.c>/,/<\/IfModule>/ s/NameVirtualHost \*:443/XXXXX/g' ports.conf | grep 'XXXXX' | wc -l`
	if [ $IS_NAMEVIRTUALHOST -eq 0 ]
	then
		sed -i -e '/<IfModule mod_ssl.c>/,/<\/IfModule>/ s/^\([\t ]*\)Listen[\t ]*443/&\n\1NameVirtualHost *:443/' ports.conf
	fi
fi
print_info "Activate SSL on Apache"
a2enmod ssl

print_info "Create Owncloud site Apache configuration"
cp $RESOURCES_PATH/owncloud /etc/apache2/sites-available/
print_info "Enable Owncloud site"
a2dissite default
a2dissite default-ssl
a2ensite owncloud
service apache2 reload

### Clean
/bin/rm -Rf $DL_PATH
program_exit
