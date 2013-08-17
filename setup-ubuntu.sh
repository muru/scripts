#! /bin/bash
# ↄ⃝ Murukesh Mohanan

# Copied from http://stackoverflow.com/questions/296536/urlencode-from-a-bash-script.
# Thanks, Orwellophile and Pumbaa80
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

# An MD5 hash of the username is pretty much certain to be not an existing directory.
# I could use /dev/random, but I'm too lazy. :P
tmpdir=~/`echo $USER | md5sum | cut -d" " -f1`
read -p "Enter your LDAP ID: " LDAPID
read -sp "Enter your LDAP password: " LDAPPSWD

LDAPENCPSWD=$( rawurlencode LDAPPSWD )

export http_proxy="http://$LDAPID:$LDAPENCPSWD@netmon.iitb.ac.in:80"
export https_proxy=$http_proxy

mkdir -p $tmpdir
cd $tmpdir
cp /etc/environment .
cp /etc/apt/sources.list .

sed -i '/_proxy/d' environment
echo http_proxy=$http_proxy >> environment
echo https_proxy=$https_proxy >> environment

# The <<"EOF" starts a here-doc, ended by the EOF on a line by itself.
cat > apt.conf <<"EOF"
Acquire::http::Proxy "http://printserver.cse.iitb.ac.in:3144/";
Acquire::http::Proxy::ftp.iitb.ac.in DEFAULT;
EOF

alias cp='cp -b'

# Guess where the checksum came from.
if echo "d088b801d5e15cc7a2d7dfba5fae7431  /etc/apt/sources.list" | md5sum -c --status; then
	echo "You seem to have a rather threadbare sources.list, I'm replacing it with a fuller one."
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
	echo "alias cp='cp -b'" >> ~/.bashrc
fi
sudo cp -b apt.conf /etc/apt/
sudo cp -b environment /etc

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
			sudo apt-get install -y emacs css-mode python-mode emacs23-el php-elisp gnuplot-mode ispell vim ctags vim-scripts vim-gnome gnuplot dia xfig fig2ps mpg123 python-pygresql python3-postgresql python php5 php5-ldap php5-pgsql subversion cscope cscope-el apache2 bison flex sharutils inkscape eclipse eclipse-cdt avidemux audacity openssh-server vnc4server xvnc4viewer
		;;
esac

read -p "Install updates? [Y|n]" option
case $option in
	[Nn])	echo "Very well."
		;;
	*)		echo "Upgrading..."
			sudo apt-get upgrade -y
		;;
esac
rm ~/apt.log
cd ~
rm -rf $tmpdir
echo "I suppose that's all. Farewell, Great Lord (or Lady, as the case may be."
