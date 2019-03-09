echo "Installing configs and aliases"
yes | cp -rf ./i3 $HOME/.config/
yes | cp -rf .bash_aliases $HOME

echo "Installing cosmetics"
yes | cp -rf ./variety $HOME/.config
yes | cp -rf ./gtk* $HOME/.config

echo "Adding PPAs"
for ppa in $(cat ppa.list);
do
	sudo add-apt-repository $ppa -y
done

sudo apt update

echo "Installing packages"
for package in $(cat packages.list);
do
	sudo apt install $package -y
done

i3-msg restart

