echo "### Installing PACMAN packages ###"

sudo pacman -Syyy

# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Install_packages_from_a_list
sudo pacman -S --needed - < pacman.list
sudo pacman -S --needed $(comm -12 <(pacman -Slq | sort) <(sort pacman.list))
sudo pacman -Rsu $(comm -23 <(pacman -Qq | sort) <(sort pacman.list))

