#! /bin/bash -x

# For a lot of these variables, if any value has been previously set,
# (for example, from the terminal before running the script), that value
# is used. Use this to override the defaults given here.

# This is where the compiled stuff will be installed
INSTALL_DIR=${INSTALL_DIR:-/opt/cs715}				
# This is where the source of GCC will be put, 
# and where I expect to find all the dependencies.
WORKING_DIR=${WORKING_DIR:-$HOME/devel}		
# This is where I compile everything
BUILD_DIR=${BUILD_DIR:-$WORKING_DIR/gcc}

GCC=${GCC:-gcc-4.7.2}
GMP=${GMP:-gmp-4.3.2}
MPC=${MPC:-mpc-0.8.2}
MPFR=${MPFR:-mpfr-3.1.2}
PPL=${PPL:-ppl-0.11.2}
CLOOG=${CLOOG:-cloog-ppl-0.15.11}

GCC_MIRROR=${GCC_MIRROR:-http://gcc.cybermirror.org/releases/$GCC}
GMP_MIRROR=${GMP_MIRROR:-https://gmplib.org/download/gmp}
MPC_MIRROR=${MPC_MIRROR:-http://www.multiprecision.org/mpc/download}
MPFR_MIRROR=${MPFR_MIRROR:-http://www.mpfr.org/$MPFR}
PPL_MIRROR=${PPL_MIRROR:-http://bugseng.com/products/ppl/download/ftp/releases/${PPL#ppl-}}
CLOOG_MIRROR=${CLOOG_MIRROR:-http://gcc.cybermirror.org/infrastructure}

if [[ ! -w $INSTALL_DIR ]] ; then
	[[ -w `dirname $INSTALL_DIR` ]] && mkdir -p $INSTALL_DIR || sudo -- sh -c "mkdir -p $INSTALL_DIR; chown $USER:$USER $INSTALL_DIR"
fi
if [[ ! -w $WORKING_DIR ]] ; then
	[[ -w `dirname $WORKING_DIR` ]] && mkdir -p $WORKING_DIR || sudo -- sh -c "mkdir -p $WORKING_DIR; chown $USER:$USER $WORKING_DIR"
fi
if [[ ! -w $BUILD_DIR ]] ; then
	[[ -w `dirname $BUILD_DIR` ]] && mkdir -p $BUILD_DIR || sudo -- sh -c "mkdir -p $BUILD_DIR; chown $USER:$USER $BUILD_DIR"
fi

cd $WORKING_DIR

# Use the SKIP_EXTRACT and SKIP_TAR_CHECK variables to avoid these two
# rather time consuming operations.

if [[ -z "$SKIP_TAR_CHECK" ]]
then
	tar -jtf $GCC.tar.bz2 >/dev/null 2>/dev/null || wget -N "$GCC_MIRROR/$GCC.tar.bz2" 
	tar -jtf $GMP.tar.bz2 >/dev/null 2>/dev/null || wget -N "$GMP_MIRROR/$GMP.tar.bz2"
	tar -ztf $MPC.tar.gz >/dev/null 2>/dev/null || wget -N "$MPC_MIRROR/$MPC.tar.gz"
	tar -jtf $MPFR.tar.bz2 >/dev/null 2>/dev/null || wget -N "$MPFR_MIRROR/$MPFR.tar.bz2"
	tar -ztf $PPL.tar.gz >/dev/null 2>/dev/null || wget -N "$PPL_MIRROR/$PPL.tar.gz"
	tar -ztf $CLOOG.tar.gz >/dev/null 2>/dev/null || wget -N "$CLOOG_MIRROR/$CLOOG.tar.gz"
fi

if [[ -z "$SKIP_EXTRACT" ]]
then
	rm -rf $BUILD_DIR/*

	tar -jxvf $GCC.tar.bz2	# Keep outside the build directory
	tar -jxvf $GMP.tar.bz2 -C $BUILD_DIR
	tar -zxvf $MPC.tar.gz -C $BUILD_DIR
	tar -jxvf $MPFR.tar.bz2 -C $BUILD_DIR
	tar -zxvf $PPL.tar.gz -C $BUILD_DIR
	tar -zxvf $CLOOG.tar.gz -C $BUILD_DIR
fi

NJOBS=`nproc`

export LD_LIBRARY_PATH=$INSTALL_DIR/lib
export LIBRARY_PATH=/usr/lib/$(gcc -print-multiarch)
export C_INCLUDE_PATH=/usr/include/$(gcc -print-multiarch)
export CPLUS_INCLUDE_PATH=/usr/include/$(gcc -print-multiarch)

cd $BUILD_DIR/$GMP
./configure --prefix=$INSTALL_DIR --enable-cxx && \
	make -j$NJOBS && \
	make install || \
	exit 2
sudo ldconfig


cd $BUILD_DIR/$MPFR
./configure --prefix=$INSTALL_DIR --with-gmp=$INSTALL_DIR && \
	make -j$NJOBS && \
	make install || \
	exit 2
sudo ldconfig

cd $BUILD_DIR/$MPC
./configure --prefix=$INSTALL_DIR --with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR && \
	make -j$NJOBS && \
	make install || \
	exit 2
sudo ldconfig


cd $BUILD_DIR/$PPL
./configure --prefix=$INSTALL_DIR --with-gmp-prefix=$INSTALL_DIR && \
	make -j$NJOBS && \
	make install || \
	# exit 2
sudo ldconfig


cd $BUILD_DIR/$CLOOG
./configure --prefix=$INSTALL_DIR --with-ppl=$INSTALL_DIR && \
	make -j$NJOBS && \
	make install || \
	exit 2
sudo ldconfig

mkdir -p $BUILD_DIR/$GCC
cd $BUILD_DIR/$GCC
$WORKING_DIR/$GCC/configure \
	--enable-languages=c,c++ --prefix=$INSTALL_DIR --program-suffix=${GCC#gcc} \
	--with-gmp=$INSTALL_DIR --with-mpfr=$INSTALL_DIR --with-mpc=$INSTALL_DIR \
	--with-ppl=$INSTALL_DIR --with-cloog=$INSTALL_DIR --disable-multilib && \
	make -j$NJOBS && \
	make install || \
	exit 2
