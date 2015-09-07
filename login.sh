#! /bin/bash
if [[ -n $1 ]]
then
	UNAME=$1
else
	read -p 'Username: ' UNAME
	[[ -z $UNAME ]] && exit 1
fi

if [[ -n $2 ]]
then
	PASSWD=$2
else
	read -sp 'Password: ' PASSWD
	[[ -z $PASSWD ]] && exit 1
fi

wget --no-proxy --quiet --post-data="uname=$UNAME&passwd=$PASSWD&submit=button" \
	https://internet.iitb.ac.in/index.php -O - | \
	grep -q window.location.href && \
	echo 'Logged in!' || \
	echo "Something's wrong."

