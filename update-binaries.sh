#!/bin/bash

INSTALL_DIRECTORY=$HOME/Documents/install

mkdir -p ./installs

for installable in $(ls $INSTALL_DIRECTORY/*/dotfiles-build);
do
  repo_name=$(awk -F/ '{print $6}' <<< "$installable")
  origin=$(cd $(dirname $installable) && git remote get-url origin)
  echo $repo_name 

  entry=./installs/$repo_name
  
  echo "$origin" > $entry
  cat $installable >> $entry
  chmod +x ./installs/$repo_name
done
