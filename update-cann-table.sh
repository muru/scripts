#! /bin/bash
set -xue

cd ~/devel/web
git pull
~/bin/table.sh | ~/bin/cann-table.py > cann-table.html
git commit -am 'updated cann-table: $(date)'
git push cse
git push origin
