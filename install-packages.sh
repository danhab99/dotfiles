echo "### Installing PACMAN packages ###"

sudo pacman -Syyy

# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Install_packages_from_a_list
sudo pacman -S --needed $(comm -12 <(pacman -Slq|sort) <(sort pkglist.txt) )
pacaur -S --noedit --noconfirm --needed localpkglist.txt

