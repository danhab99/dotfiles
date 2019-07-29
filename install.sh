lwd=$(pwd)
cd $HOME/Documents/dotfiles
git pull origin master

echo "Installing configs and aliases"
yes | cp -rf ./i3 $HOME/.config/
yes | cp -rf .bash_aliases $HOME
yes | cp -rf .bash_paths $HOME
yes | cp -rf .bashrc $HOME

echo "Installing cosmetics"
yes | cp -rf ./gtk* $HOME/.config

echo "Installing wallpaper slideshow"
mkdir -p $HOME/Pictures/wallpaper/.cache
yes | cp -f  ./slideshow.sh $HOME/Pictures/wallpaper
yes | cp -f  ./changewallpaper.sh $HOME/Pictures/wallpaper

echo "Installing rofi"
yes | cp -rf ./rofi/* $HOME/.local/share/rofi/themes

echo "Installing zsh"
cp .zshrc $HOME/.zshrc
cp -r ./oh-my-zsh/* $HOME/.oh-my-zsh

echo "Installing commands"
ln -s $HOME/Documents/dotfiles/update.sh $HOME/.local/bin/dotfiles-update
ln -s $HOME/Documents/dotfiles/install.sh $HOME/.local/bin/dotfiles-install
ln -s $HOME/Pictures/wallpaper/changewallpaper.sh $HOME/.local/bin/changewallpaper

read -p "Do you want to install the packages [N/y]" yn

if [[ ! yn =~ ^[Nn]$ ]];  then
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

	ls `npm root -g` > /tmp/npm.list

	for package in $(diff -u /tmp/npm.list npm.list | grep -Po "(?<=\+)[a-zA-Z].*");do
		echo "### Installing npm $package ###"
		sudo npm install -g $package
	done
fi

i3-msg restart
cd $lwd
