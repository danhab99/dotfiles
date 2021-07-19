echo "### Updating PACMAN packages ###"

if [ -f "pacman.list" ]; then
  rm pacman.list
fi
pacman -Qe > pacman.list

