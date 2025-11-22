#! /bin/bash
# ↄ⃝ Murukesh Mohanan
# This script gets the current Premier League table and prints
# it as a Cann table in HTML. The functions print the table in
# CSV amd the python script parses it to print the HTML table.
# It takes no arguments.
#
# The grep commands filter out only the table data. The sed
# commands then remove the HTML tags, strip extra spaces and
# unnecessary guff and then tr converts it to CSV, followed
# by some tidying-up.

function table_bbc2 () {
	child_selecter='section[aria-labelledby="tab-PremierLeague"] tr td:nth-child'
	curl -Ls http://www.bbc.com/sport/football/tables |
		pup "$child_selecter(1) a, $child_selecter(2), $child_selecter(8), $child_selecter(9) text{}" |
		awk '{b=(NR-1)%20;a[b] = a[b] "," $0} END{for (i = 0; i < 20 ;i++)print a[i]}' |
		sed 's/^,//'
}

table_bbc2; exit $?

function table_bbc () {
	curl -Ls http://www.bbc.com/sport/football/tables |
		sed -rn '/team-name/s/.*team-name.*>([A-Z][A-Za-z ]*)<.*/\1/p;/points|goal-difference/s/.*>(-?[0-9]*)<.*/\1/p' |
		awk 'NR % 3 {printf "%s, ", $0; next} 1'
}

function table_pl () {
	curl -s "http://www.premierleague.com/en-gb/matchday/league-table.html" |
		grep -E  'col-(pos|lp|club|[pwdl]|g[fad]|pts)' |
		tr '\r\n()' ' ' |
		sed 's/<[^>]*>//g;s/ \+/ /g;s/POS[A-Z ]*$//;s/[0-9]\+ [0-9]\+ [A-Z]/\n&/g;s/^ *//;s/\([a-z]\) \([A-Z]\)/\1:\2/g' |
		sed 's/ *$//' |
		tr ' ' ',' |
		tr ':' ' '
	echo
}

# table_pl | cann-table.py
