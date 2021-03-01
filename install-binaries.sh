#!/bin/bash

INSTALL_DIRECTORY=$HOME/Documents/install
CWD=$(pwd)

for installable in $(ls ./installs);
do
  url=$(head -n1 $installable)
  name=$(basename $installable)
  git clone $url $INSTALL_DIRECTORY/$name
  cat ./installs/$installable | sed '1d' > $INSTALL_DIRECTORY/$name/dotfiles-build
  cd $INSTALL_DIRECTORY/$name
  chmod +x dotfiles-build
  echo "### Running $installable ###"
  ./dotfiles-build
done
