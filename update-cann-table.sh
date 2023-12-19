#! /bin/bash
set -xue
PATH="$HOME/bin:$PATH"

cd ~/dev/web
git pull
~/bin/table.sh > ~/.cache/cann-table-new.csv
if diff -q ~/.cache/cann-table-new.csv ~/.cache/cann-table.csv
then
	echo No changes in the PL table.
	exit
fi
mv ~/.cache/cann-table-new.csv ~/.cache/cann-table.csv
~/bin/cann-table.py < ~/.cache/cann-table.csv > cann-table.html
git commit -am "updated cann-table: $(date)"
git push origin
