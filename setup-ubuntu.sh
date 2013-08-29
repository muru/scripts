#! /bin/bash
# ↄ⃝ Murukesh Mohanan
# This script asks the user for their LDAP username and password,
# and then sets up proxy variables in /etc/environment and /etc/apt/apt.conf.
# It also sets proxy variables in /etc/bash.bashrc, even though I think this 
# is not needed. It also exports these variables for the current session.
# Then it proceeds to test them by updating APT.
#
# Optionally, it can install software for CS699 (and other courses - planned)
# and any updates in general.

# Copied from http://stackoverflow.com/questions/296536/urlencode-from-a-bash-script.
# Thanks, Orwellophile and Pumbaa80.
# This function encodes the input, (here the LDAP password), in a format suitable
# for use in a URL. There are other cleaner, quicker ways, but these have certain
# dependencies (such as curl or a certain sed script) which aren't available on a 
# base Ubuntu desktop installation.
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

# I need a temporary directory, for intermediate files.
# An MD5 hash of the username is pretty much certain to be not an existing 
# directory. At the same time, it is constant, repeat runs won't create
# more directories. I could use /dev/random, but I'm too lazy to work out 
# the problem of leftover directories from previous runs. :P

tmpdir=~/`echo $USER | md5sum | cut -d" " -f1`

# The LDAP password prompt is a password prompt (the -s), it doesn't
# show what is being typed.
read -p "Enter your LDAP ID: " LDAPID
read -sp "Enter your LDAP password: " LDAPPSWD

echo -e \n "Setting up proxy variables..."
# Only the password needs to be encoded now, since the username is almost 
# certain to be safe. I'll have to examine the rules governing the username
# and maybe encode the username too.
LDAPENCPSWD=$( rawurlencode $LDAPPSWD )

export http_proxy="http://$LDAPID:$LDAPENCPSWD@netmon.iitb.ac.in:80"
export https_proxy=$http_proxy

# Create our working directory and copy the files here for modification.
mkdir -p $tmpdir
cd $tmpdir
cp /etc/environment .
cp /etc/bash.bashrc .
cp /etc/apt/sources.list .

# Delete existing proxy settings.
sed -i '/_proxy/d' environment bash.bashrc

echo http_proxy=$http_proxy >> environment
echo https_proxy=$https_proxy >> environment
echo export http_proxy=$http_proxy >> bash.bashrc
echo export https_proxy=$http_proxy >> bash.bashrc

# The <<"EOF" starts a here-doc, ended by the EOF on a line by itself.
# Note the quotes around EOF. Without the quotes, I could write the echos
# above as here-docs too.
cat > apt.conf <<"EOF"
Acquire::http::Proxy "http://printserver.cse.iitb.ac.in:3144/";
Acquire::http::Proxy::ftp.iitb.ac.in DEFAULT;
EOF

# I want backups of every file I'm overwriting.
alias cp='cp -b'

# I'll replace sources.list if it isn't using the IITB mirror, or
# if it is missing a few marbles. I should replace the checksum
# check with another.
REPLACE_SOURCES=0
# Guess where the checksum came from.
if echo "d088b801d5e15cc7a2d7dfba5fae7431  /etc/apt/sources.list" | md5sum -c --status ; then
	echo "You seem to have a rather threadbare sources.list, 
	I'm replacing it with a fuller one."
	REPLACE_SOURCES=1
	echo "alias cp='cp -b'" >> bash.bashrc
elif grep -qv iitb /etc/apt/sources.list; then
	echo "I'm replacing your sources.list with one using ftp.iitb.ac.in as the mirror."
	REPLACE_SOURCES=1
fi

if [[ $REPLACE_SOURCES -ne 0 ]]; then
# This here-doc contains my lab computer's sources.list.
	cat >sources.list <<"EOF"
# deb cdrom:[Ubuntu 12.04.2 LTS _Precise Pangolin_ - Release amd64 (20130213)]/ dists/precise/main/binary-i386/

# deb cdrom:[Ubuntu 12.04.2 LTS _Precise Pangolin_ - Release amd64 (20130213)]/ dists/precise/restricted/binary-i386/
# deb cdrom:[Ubuntu 12.04.2 LTS _Precise Pangolin_ - Release amd64 (20130213)]/ precise main restricted

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise universe
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise multiverse
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise-backports main restricted universe multiverse

deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise-security main restricted
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise-security universe
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise-security multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
deb http://archive.canonical.com/ubuntu precise partner
# deb-src http://archive.canonical.com/ubuntu precise partner

## This software is not part of Ubuntu, but is offered by third-party
## developers who want to ship their latest software.
deb http://extras.ubuntu.com/ubuntu precise main
# deb-src http://extras.ubuntu.com/ubuntu precise main
deb ftp://ftp.iitb.ac.in/distributions/ubuntu/archives/ precise-proposed restricted main multiverse universe
EOF
	release=`lsb_release -c | cut -f2`
	sed -i "s/precise/$release/g" sources.list
	sudo cp -b sources.list /etc/apt/
fi

# Overwrite the originals while keeping backups.
sudo cp -b apt.conf /etc/apt/
sudo cp -b environment bash.bashrc /etc

echo "Testing the settings by updating apt:"
echo "sudo apt-get update"
if sudo apt-get update >~/apt.log; then
	echo "APT seems to working fine."
else
	echo "Something went wrong. I'll exit without removing any temporary files."
	echo "Check $tmpdir and ~/apt.log for details."
	exit 1
fi

read -p "Install the CS699 requirements? [Y|n]" option
case $option in
	[Nn])	echo "Very well."
		;;
	*)		echo "Installing..."
			echo "sudo apt-get install -y emacs css-mode python-mode emacs23-el php-elisp 
				gnuplot-mode ispell vim ctags vim-scripts vim-gnome gnuplot dia xfig 
				fig2ps mpg123 python-pygresql python3-postgresql python php5 php5-ldap 
				php5-pgsql subversion cscope cscope-el apache2 bison flex sharutils 
				inkscape eclipse eclipse-cdt avidemux audacity openssh-server 
				vnc4server xvnc4viewer abs-guide"
			sudo apt-get install -y emacs css-mode python-mode emacs23-el php-elisp \
				gnuplot-mode ispell vim ctags vim-scripts vim-gnome gnuplot dia xfig \
				fig2ps mpg123 python-pygresql python3-postgresql python php5 php5-ldap \
				php5-pgsql subversion cscope cscope-el apache2 bison flex sharutils \
				inkscape eclipse eclipse-cdt avidemux audacity openssh-server \
				vnc4server xvnc4viewer abs-guide
## TODO: Add texlive packages here.
		;;
esac

read -p "Install updates? [Y|n]" option
case $option in
	[Nn])	echo "Very well."
		;;
	*)		echo "Upgrading..."
			echo "sudo apt-get upgrade -y"
			sudo apt-get upgrade -y
		;;
esac

# Cleanup.
rm ~/apt.log
cd ~
rm -rf $tmpdir
echo "I suppose that's all. Farewell, Great Lord (or Lady, as the case may be)."
