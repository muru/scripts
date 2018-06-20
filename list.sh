#! /bin/bash

file="$1"
action="$2"

. ~/.config/magnets.env
log=$listdir/../log.txt

cd "$listdir"
case $action in
	*IN_DELETE*)
		grep -vF "$file" "$log" | sponge "$log"
		;;
	*IN_MOVED_TO*|*IN_CREATE*)
		find "$file" -type f -iname '*S[0-9]*E[0-9]*' -printf "$host/stuff/Running shows/%p\n" >> "$log"
		;;
esac
