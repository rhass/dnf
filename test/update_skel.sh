#!/bin/bash
set -x

git remote add skeleton git@github.com:pantheon-cookbooks/skel.git
set -e
git fetch skeleton
git merge -X theirs -m 'skeleton cookbook sync' --squash skeleton/master

# Rename any non-conflicting skel files and stage them for commit
for f in $(ls *.skel .*.skel) ; do
  git mv -k "$f" "${f/.skel/}"
done
