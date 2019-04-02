lwd=$(pwd)
cd $HOME/Documents/dotfiles
git pull origin master

echo "Installing configs and aliases"
yes | cp -rf ./i3 $HOME/.config/
yes | cp -rf .bash_aliases $HOME

echo "Installing cosmetics"
#yes | cp -rf ./variety $HOME/.config
yes | cp -rf ./gtk* $HOME/.config

echo "Installing wallpaper slideshow"
mkdir -p $HOME/Pictures/wallpaper/.cache
yes | cp -f  ./slideshow.sh $HOME/Pictures/wallpaper
yes | cp -f  ./changewallpaper.sh $HOME/Pictures/wallpaper

echo "Installing rofi"
yes | cp -rf ./rofi/themes $HOME/.local/share/rofi/themes

echo "Installing commands"
ln -s $HOME/Documents/dotfiles/update.sh $HOME/.local/bin/dotfiles-update
ln -s $HOME/Documents/dotfiles/install.sh $HOME/.local/bin/dotfiles-install
ln -s $HOME/Pictures/wallpaper/changewallpaper.sh $HOME/.local/bin/changewallpaper

echo "Do you want to install the packages [N/y]"
read doInstall

if [ $doInstall == "N" || $doInstall == "" ];  then
	echo "Skipping"
else
	echo "Adding PPAs"
	apt-cache policy | grep http | awk '{print $2 $3}' | sort -u > /tmp/ppa.list

	for ppa in $(diff -u /tmp/ppa.list ppa.list | grep -Po "(?<=\+)http.*");
	do
		echo "### Adding $ppa ###"
		sudo add-apt-repository $ppa -y
	done

	sudo apt update

	echo "Installing packages"
	apt-mark showmanual > /tmp/packages.list

	for package in $(diff -u /tmp/packages.list packages.list | grep -Po "(?<=\+)[a-zA-Z].*");
	do
		echo "### Installing $package ###"
		sudo apt install $package -y
	done
fi

i3-msg restart
cd $lwd
