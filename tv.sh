#! /bin/bash

log () {
	[[ -z $verbose ]] || echo "$@" >&2
}

[[ $1 = "-v" ]] && verbose=1

if xrandr | grep -q 'Screen.*1920 x 1080'
then
	log "Extending displays..."
	xrandr --output DP-1 --primary --below HDMI-0
else 
	log "Mirroring displays..."
	xrandr --output DP-1 --same-as HDMI-0
fi

sleep 2

log "Setting sound ..."
tv=SONY
read -r card profile < <(pactl list cards | awk -v "tv=$tv" '$1 ~ /Name:/ {name = $2} /device.product.name/ && ($0 ~ tv) {p = 1} p && /Part of profile/ {print name, $NF; exit}')
pacmd set-card-profile "$card" "$profile"
