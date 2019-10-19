#! /bin/bash
set -xue
PATH="$HOME/bin:$PATH"

cd ~/dev/web
git pull
~/bin/table.sh | ~/bin/cann-table.py > cann-table.html
git commit -am "updated cann-table: $(date)"
git push origin
