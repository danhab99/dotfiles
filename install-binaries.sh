#!/bin/bash

INSTALL_DIRECTORY=$HOME/Documents/install
CWD=$(pwd)

for installable in $(ls ./installs);
do
  path=$CWD/installs/$installable
  url=$(head -n1 $path)
  name=$(basename $path)
  git clone $url $INSTALL_DIRECTORY/$name
  cat ./installs/$installable | sed '1d' > $INSTALL_DIRECTORY/$name/dotfiles-build
  cd $INSTALL_DIRECTORY/$name
  chmod +x dotfiles-build
  echo "### Running $installable ###"
  ./dotfiles-build
  cd $CWD
done
