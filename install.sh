lwd=$(pwd)
cd $HOME/Documents/dotfiles
git pull origin master

echo "Installing configs and aliases"
yes | cp -rf ./i3 $HOME/.config/
yes | cp -rf .bash_aliases $HOME
yes | cp -rf .bash_paths $HOME
yes | cp -rf .bashrc $HOME

echo "Installing cosmetics"
yes | cp -rf ./gtk* $HOME/

echo "Installing wallpaper slideshow"
mkdir -p $HOME/Pictures/wallpaper/.cache
yes | cp -f  ./slideshow.sh $HOME/Pictures/wallpaper
yes | cp -f  ./changewallpaper.sh $HOME/Pictures/wallpaper

echo "Installing rofi"
yes | cp -rf ./rofi/* $HOME/.local/share/rofi/themes

echo "Installing zsh"
cp .zshrc $HOME/.zshrc
cp -r ./oh-my-zsh/* $HOME/.oh-my-zsh/

echo "Installing commands"
mkdir -p $HOME/.local/bin
ln -s $HOME/Documents/dotfiles/update.sh $HOME/.local/bin/dotfiles-update
ln -s $HOME/Documents/dotfiles/install.sh $HOME/.local/bin/dotfiles-install
ln -s $HOME/Pictures/wallpaper/changewallpaper.sh $HOME/.local/bin/changewallpaper

i3-msg restart
cd $lwd
