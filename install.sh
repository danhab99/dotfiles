lwd=$(pwd)
cd $HOME/Documents/dotfiles
git pull origin master

echo "Installing configs and aliases"
yes | cp -rf ./i3 $HOME/.config/
yes | cp -rf ./dunst $HOME/.config/
yes | cp -rf .bash_aliases $HOME
yes | cp -rf .bash_paths $HOME
yes | cp -rf .bashrc $HOME
yes | cp -rf ./.X* $HOME
yes | cp -rf ./g600 $HOME/.config

echo "Installing rofi"
mkdir -p $HOME/.local/share/rofi
yes | cp -rf ./rofi $HOME/.local/share/rofi/themes

echo "Installing zsh"
cp .zshrc $HOME/.zshrc
cp -r ./oh-my-zsh $HOME/.oh-my-zsh

echo "Installing commands"
mkdir -p $HOME/.local/bin
ln -s $HOME/Documents/dotfiles/update.sh $HOME/.local/bin/dotfiles-update
ln -s $HOME/Documents/dotfiles/install.sh $HOME/.local/bin/dotfiles-install

echo "Installing vimrc"
cp -r ./.vim* $HOME

i3-msg restart
cd $lwd
