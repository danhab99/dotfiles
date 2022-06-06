echo "### Updating PACMAN packages ###"

pacman -Qqen > pkglist.txt
pacman -Qqem > localpkglist.txt
