#! /bin/bash
cd ~/devel/cassandra
git pull muru gh-pages:gh-pages
git checkout gh-pages
git fetch origin trunk:trunk
./gen.sh
git push muru gh-pages:gh-pages
