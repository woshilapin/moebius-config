#!/bin/bash

print_info "Choosing the name of the device"
df -h
print_info "Enter the name of the device [/dev/disk1s1]: \c"
read PARTITION
if test -z $PARTITION;
then
	PARTITION="/dev/disk1s1"
fi
DEVICE=`echo $PARTITION | sed 's+/dev/disk\([0-9]*\)s\([0-9]*\)+/dev/rdisk\1+g'`
print_info "Choosing the image to install"
NUM=1
for file in `ls $IMG_PATH/`
do
	echo "[$NUM] $file"
	NUM=$[$NUM+1]
done
print_info "Enter the number of the image to install [1]: \c"
read CHOSEN_NUM
if test -z $CHOSEN_NUM;
then
	CHOSEN_NUM="1"
fi
NUM=1
for file in `ls $IMG_PATH/`
do
	CHOSEN_FILE=""
	if test $NUM -eq $CHOSEN_NUM;
	then
		CHOSEN_FILE=$file
		break
	fi
	NUM=$[$NUM+1]
done
if test -z $CHOSEN_FILE;
then
	print_err "You should give a number to choose the image to install."
fi

print_info "Uncompressing the image"
BASE="${CHOSEN_FILE%.[^.]*}"
EXT="${CHOSEN_FILE:${#BASE} + 1}"
mkdir $UNZIP_PATH
cd $UNZIP_PATH
case $EXT in
	"zip")
		unzip $IMG_PATH/$CHOSEN_FILE
		;;
	"gz")
		tar xvzf $IMG_PATH/$CHOSEN_FILE
		;;
	"bz2")
		tar xvjf $IMG_PATH/$CHOSEN_FILE
		;;
esac
print_info "Unmounting the current SD partition on `hostname -s`"
sudo diskutil unmount $PARTITION
print_info "Setting up the image on SD card"
print_info "You can use <CTRL>+t to see the status of the transfert"
IMG=`ls $UNZIP_PATH/*`
dd bs=1m if=$IMG of=$DEVICE || program_exit
print_info "Ejecting the SD card on `hostname -s`"
sudo diskutil eject $DEVICE

print_info "The card has been ejected"
print_info "Please plug the SD card into your raspberrypi then press ENTER"
read NULL
