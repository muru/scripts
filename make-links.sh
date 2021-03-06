#! /bin/bash

die() { echo $1 1>&2; exit 1; }

if [ $# -lt 2 ]; then
	die "At least one folder name please."
fi

EXT=$3

FROM_DIR="$1"
if [[ -z $2 ]]; then
	TO_DIR="$PWD"
else 
	TO_DIR="$2"
fi

cd "$TO_DIR"
for file in $FROM_DIR/*$EXT;
do 
	target=`basename "$file"`
	if [[ -f $file && ! -f $target ]]; then
		echo From $file to $PWD/$target...
		ln -s "$file" "$TO_DIR/$target"
	else
		echo Skipping $file..
	fi
done

