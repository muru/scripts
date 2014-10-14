#! /usr/bin/python3
# ↄ⃝ Murukesh Mohanan
# This script reads in the PL table in CSV form from standard input,
# then prints it back out as a Cann table in HTML.
# Currently hard-coded to the PL site's format, but 
# we can fix that using the header line.

import sys
import csv
from time import strftime, localtime

csvr = csv.reader(sys.stdin)
header = next(csvr)
indexheader = {v:i for i,v in enumerate(header)}
table = [[int(x) if not x[0].isalpha() else x for x in row] for row in csvr]

count=0

print('<table id="cann-table">')
print('<thead> <th> Pts </th> <th> Clubs (GD) </th> </thead>')

for pt in range(table[0][-1], table[-1][-1] - 1, -1):
	clubs = [[row[2], row[-2]] for row in table if row[-1] == pt]
	label = '1' if count < 3 else '2'
	count = (count + 1) % 6

	print('\t<tr class="cann-row-' + label + '">') 
	print('\t\t<td class="cann-point">', pt, '</td>')
	print('\t\t<td class="cann-clubs">')
	
	for club in clubs:
		print('\t\t\t<span class="club-name">', club[0], '(' + str(club[1]) + ')', '</span>')
	print('\t\t</td>\n', '\t</tr>')

print('</table>')
print('<span id="cann-gen-note"> Generated on ', strftime("%A, %d %B %Y at %H:%M %Z.", localtime()), '</span>')
