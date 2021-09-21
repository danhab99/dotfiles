
if [[  $1 = "restore"  ]]; then
  echo "Restoring work directory $(cat $HOME/.config/lastworkdir)"
  cp $HOME/.config/lastworkdir /tmp/workdir
  cd "$(cat $HOME/.config/lastworkdir)"
else
  echo "Setting work directory to $(pwd)"
  echo "$( pwd )" > /tmp/workdir
  echo "$( pwd )" > $HOME/.config/lastworkdir
fi
