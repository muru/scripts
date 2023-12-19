#! /usr/bin/python3
# ↄ⃝ Murukesh Mohanan
# This script reads in the PL table in CSV form from standard input,
# then prints it back out as a Cann table in HTML.
# Currently hard-coded to the PL site's format, but
# we can fix that using the header line.

import sys
import csv
from time import strftime, localtime
import pprint

csvr = csv.reader(sys.stdin)
table = [[int(x) if not x[0].isalpha() else x for x in row] for row in csvr]
matchweek = max(row[1] for row in table)

count = 0
footnotes = False
timestamp = strftime("%A, %d %B %Y at %H:%M %Z", localtime())

print('<table id="cann-table">')
print("<thead> <th> Pts </th> <th> Clubs (GD) </th> </thead>")

for point in range(table[0][-1], table[-1][-1] - 1, -1):
    entries = [[row[0], row[1], row[2]] for row in table if row[-1] == point]
    label = "1" if count < 3 else "2"
    count = (count + 1) % 6

    print(f'\t<tr class="cann-row-{label}">')
    print(f'\t\t<td class="cann-point">{point}</td>')
    print('\t\t<td class="cann-clubs">')

    for entry in entries:
        club, matches_played, goal_difference = entry
        note = ""
        if games_in_hand := (matchweek - matches_played):
            footnotes = True
            note = '*'*games_in_hand

        print(f'\t\t\t<span class="club-name">{club}{note} ({goal_difference})</span>')
    print("\t\t</td>\n", "\t</tr>")

print("</table>")
if footnotes:
    note = "<br>* Each asterisk is a match in hand."
print(f'<span id="cann-gen-note"> Generated on {timestamp}.{note}</span>')
