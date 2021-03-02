lwd=$(pwd)
cd $HOME/Documents/dotfiles

echo "Copying configs"
cp -r $HOME/.config/i3 .
cp -r $HOME/.config/dunst .
cp $HOME/.bash_aliases .bash_aliases
cp $HOME/.bash_paths .bash_paths
cp $HOME/.bashrc .bashrc
cp $HOME/.X* .

echo "Copying packages"
apt-mark showmanual > packages.list

#echo "Copying ppas"
#apt-cache policy | grep http | awk '{print $2 $3}' | sort -u > ppa.list

echo "Copying source list"
cp /etc/apt/sources.list .

echo "Copying brew"
brew list --formula > brew.list

echo "Copying npm globals"
ls `npm root -g` > npm.list

echo "Copying zsh"
cp $HOME/.zshrc ./.zshrc
cp -r $HOME/.oh-my-zsh/* ./oh-my-zsh/

echo "Copying bashrc"

#echo "Copying variety"
#cp -r $HOME/.config/variety ./

echo "Copying gtk*"
cp -r $HOME/.config/gtk* ./

echo "Copying scripts"
cp $HOME/Pictures/wallpaper/*.sh ./
cp $HOME/Documents/clipboard/*.sh ./clipboard/

echo "Copying rofi"
cp -r $HOME/.local/share/rofi/themes/* ./rofi/

echo "Copying g600 macros"
cp -r $HOME/.config/g600/ .

echo "Copying vimrc"
cp $HOME/.vim* ./

echo "Copying nitrogen"
cp -r $HOME/.config/nitrogen .

echo "Updating binaries"
./update-binaries.sh

echo "COMITTING"
git add .
git diff-tree --no-commit-id --name-only -r HEAD
git commit . -m "$(date)"
git push origin master

cd $lwd
