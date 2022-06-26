lwd=$(pwd)
cd $HOME/Documents/dotfiles

function grab() {
  cp -r $1 .
}

echo "Copying configs"
grab $HOME/.config/i3
grab $HOME/.config/dunst
grab $HOME/.bash_aliases
grab $HOME/.bash_paths
grab $HOME/.bashrc
grab $HOME/.X*

echo "Copying zsh"
grab $HOME/.zshrc 
grab $HOME/.oh-my-zsh

echo "Copying rofi"
grab $HOME/.local/share/rofi/themes

echo "Copying g600 macros"
grab $HOME/.config/g600

echo "Copying vimrc"
grab $HOME/.vimrc
cp -r $HOME/.vim/colors ./.vim
cp -r $HOME/.vim/syntax ./.vim

echo "Copying tmux config"
grab $HOME/.tmux.conf

echo "Updating binaries"
./update-binaries.sh

echo "Updating packages"
./update-packages.sh

echo "COMITTING"
git add .
git diff-tree --no-commit-id --name-only -r HEAD
git commit . -m "$(date)"
git push origin master

cd $lwd
