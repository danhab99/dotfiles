lwd=$(pwd)
cd $HOME/Documents/dotfiles

echo "Copying configs"
cp -r $HOME/.config/i3 .
cp -r $HOME/.config/dunst .
cp $HOME/.bash_aliases .bash_aliases
cp $HOME/.bash_paths .bash_paths
cp $HOME/.bashrc .bashrc
cp $HOME/.X* .

echo "Copying zsh"
cp $HOME/.zshrc ./.zshrc
cp -r $HOME/.oh-my-zsh/* ./oh-my-zsh/

echo "Copying rofi"
cp -r $HOME/.local/share/rofi/themes/* ./rofi/

echo "Copying g600 macros"
cp -r $HOME/.config/g600/ .

echo "Copying vimrc"
cp -r $HOME/.vimrc .

echo "Copying nitrogen"
cp -r $HOME/.config/nitrogen .

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
