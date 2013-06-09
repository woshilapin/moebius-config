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
SSL_CRL_PATH=$SSL_PATH/crl
SSL_PRIVATE_PATH=$SSL_PATH/private

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
	md5sum owncloud-4.5.1.tar.bz2
print_info "Uncompressing owncloud"
cd $WWW_PATH && \
	tar xvjf $DL_PATH/owncloud-4.5.1.tar.bz2
print_info "Initializing owncloud"
chown -R www-data:www-data $WWW_PATH/owncloud/

print_info "Initialize SSL directories"
mkdir -p $SSL_PATH
mkdir -p $SSL_CERTS_PATH
mkdir -p $SSL_CRL_PATH
mkdir -p $SSL_PRIVATE_PATH
echo 01 > $SSL_PATH/serial
touch $SSL_PATH/index.txt
SSL_CNF_FILE=$SSL_PATH/openssl.cnf
cp /usr/lib/ssl/openssl.cnf $SSL_CNF_FILE
print_info "Initialize SSL configuration"
sed -i 's+^\(dir[ ]*=\).*$+\1 '$SSL_PATH'+' $SSL_CNF_FILE
sed -i 's/\(countryName_default[ ]*=\).*$/\1 FR/' $SSL_CNF_FILE
sed -i 's/\(stateOrProvinceName_default[ ]*=\).*$/\1 IDF/' $SSL_CNF_FILE
sed -i 's/\(localityName[ ]*=\).*$/\1 Paris/' $SSL_CNF_FILE
sed -i 's/\(0.organizationName_default[ ]*=\).*$/\1 Tuziwo/' $SSL_CNF_FILE
sed -i 's/\(commonName[ ]*=\).*$/\1 woshilapin/' $SSL_CNF_FILE
sed -i 's/\(emailAddress[ ]*=\).*$/\1 woshilapin@gmail.com/' $SSL_CNF_FILE
print_info "Create a private key (enter a strong password) as a CA*"
print_info "(*) CA: Certificate Authority"
SSL_CA_PRIVATE_KEY_FILE=$SSL_PRIVATE_PATH/ca-key.pem
openssl genrsa \
	-des3 \
	-out $SSL_CA_PRIVATE_KEY_FILE \
	4096
print_info "Create a signed certificate as a CA*"
print_info "(*) CA: Certificate Authority"
SSL_CA_CERT_FILE=$SSL_PATH/ca-cert.pem
openssl req \
	-config $SSL_CNF_FILE \
	-new \
	-x509 \
	-nodes \
	-sha1 \
	-days 1 \
	-key $SSL_CA_PRIVATE_KEY_FILE \
	-out $SSL_CA_CERT_FILE
print_info "Create a private key (enter a strong password)"
FQDN_NAME=owncloud
SSL_PRIVATE_KEY_FILE=$SSL_PRIVATE_PATH/$FQDN_NAME-key.pem
openssl genrsa \
	-des3 \
	-out $SSL_PRIVATE_KEY_FILE \
	4096
print_info "Create a certificate"
print_info "Fill with following informations:"
print_info "- Country Name = FR"
print_info "- State or Province Name = IDF"
print_info "- Locality Name = Paris"
print_info "- Organization Name = tuziwo"
print_info "- Common Name = tuziwo.no-ip.org"
print_info "- Email Address = woshilapin@gmail.com"
SSL_CSR_FILE=$SSL_PATH/$FQDN_NAME-csr.pem
openssl req \
	-config $SSL_CNF_FILE \
	-new \
	-key $SSL_PRIVATE_KEY_FILE \
	-out $SSL_CSR_FILE
print_info "Sign the certificate"
SSL_CERT_FILE=$SSL_PATH/$FQDN_NAME-cert.pem
echo "y" | openssl ca \
	-config $SSL_CNF_FILE \
	-policy policy_anything \
	-out $SSL_CERT_FILE \
	-infiles $SSL_CSR_FILE
print_info "Create a no-key private key (from private key)"
SSL_PRIVATE_KEY_NOPASS_FILE=`echo $SSL_PRIVATE_PATH/$FQDN_NAME-key.pem |
	sed 's/-key/-key.nopass/'`
openssl rsa \
	-in $SSL_PRIVATE_KEY_FILE \
	-out $SSL_PRIVATE_KEY_NOPASS_FILE

print_info "Configure Apache with certificates"
mkdir -p $SSL_PATH/$FQDN_NAME
mv $SSL_PATH/$FQDN_NAME-* $SSL_PATH/$FQDN_NAME/
print_info "Configure SSL on Apache"
IS_NAMEVIRTUALHOST=`grep 'NameVirtualHost \*:443' | wc -l`
if [ $IS_NAMEVIRTUALHOST -eq 0 ]
then
	echo 'NameVirtualHost *:443' >> /etc/apache2/ports.conf
fi
IS_LISTEN=`grep 'Listen 443' | wc -l`
if [ $IS_LISTEN -eq 0 ]
then
	echo 'Listen 443' >> /etc/apache2/ports.conf
fi
print_info "Activate SSL on Apache"
a2enmod ssl

print_info "Create Owncloud site Apache configuration"
cp $RESOURCES_PATH/owncloud /etc/apache2/sites-available/
print_info "Enable Owncloud site"
a2ensite owncloud

### Clean
program_exit
