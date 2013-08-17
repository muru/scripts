#! /bin/bash
# ↄ⃝ Murukesh Mohanan

if [[ $# -eq 0 ]]; then
	SPPFILE='simplecpp.tar.gz'
else
	SPPFILE=$1
fi

if [[ $# -eq 2 ]]; then
	SPPDIR=$2
else
	SPPDIR=~/Desktop/simplecpp
fi

tar -xvf $SPPFILE -C $SPPDIR/.. 1>&2 2>spperror.log

sudo apt-get install g++ libx11-dev vim 1>&2 2>spperror.log

if [[ $? -eq 0 ]]; then
	cd $SPPDIR
	chmod +x configure.sh
	if ./configure.sh 1>&2 2>spperror.log; then
		echo Setting environment variables...
		echo PATH=\$PATH:$SPPDIR | tee ~/.bashrc
		echo LIBSPP=$SPPDIR/lib | tee ~/.bashrc
		echo INCLSPP=$SPPDIR/include | tee ~/.bashrc
		. ~/.bashrc
	else
		echo "Configuring simplec++ failed. Environment variables won't be modified. Check spperror.log for details."
	fi
else
	echo "Error: Couldn't install dependencies. Check spperror.log for details."
fi
