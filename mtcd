#! /bin/bash

ISODIR=$PWD
CDROOT=~/cdrom
if [ ! -d $CDROOT ]; then
    mkdir -p $CDROOT
fi

COUNT=`/bin/ls -1 --reverse $CDROOT/ | head -1`
#cd $CDROOT

for ISO in $@; do
    let COUNT=$COUNT+1
    mkdir $CDROOT/$COUNT 
    sudo mount -t iso9660 $ISO $CDROOT/$COUNT
    if [[ $? -ne 0 ]]; then
        rmdir $CDROOT/$COUNT
    fi
done

if [[ $# -eq 0 ]]; then
    cd $CDROOT
    for i in *; do
        sudo umount $i
        rmdir $i
    done
fi
