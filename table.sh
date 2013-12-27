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

function table_bbc () {
	echo -n Pos.,Team,P,W,D,L,GD,Pts.
	curl -s 'http://www.bbc.com/sport/football/tables?filter=competition-118996114' | 
		grep -E '<td class=.(position|team|played|won|drawn|lost|goal|points)' |
		sed 's/<[^>]*>//g;s/No movement//' | 
		tr '\n' ' ' | 
		sed 's/ \+/ /g;s/\([a-z]\) \([A-Z]\)/\1:\2/g;s/[0-9]\+ [A-Z]/\n&/g;' 
	echo
}
# table_bbc | sed 's/ \+$//;s/ /,/g;s/:/ /'

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

table_pl | cann-table.py
