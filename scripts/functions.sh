#!/bin/bash

function print_err {
	echo "`basename $0`: error: $1"
	exit 1
}

function print_info {
	echo -e "---> $1"
}

function progress_bar {
	percDone=$(echo 'scale=2;'$1/$2*100 | bc)
	barLen=$(echo ${percDone%'.00'})
	bar=''
	fills=''
	for (( b=0; b<$barLen; b++ ))
	do
		bar=$bar"#"
	done
	blankSpaces=$(echo $((100-$barLen)))
	for (( f=0; f<$blankSpaces; f++ ))
	do
		fills=$fills"_"
	done
	echo -e -n '['$bar$fills'] - '$barLen'%\r'
}

function sectohourminsec {
	if test -z $1
	then
		echo "Usage: $(basename $0) <seconds>"
		exit
	fi
	local S=${1}
	((h=S/3600))
	((m=S%3600/60))
	((s=S%60))
	printf "%dh:%dm:%ds\n" $h $m $s
}
