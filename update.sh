lwd=$(pwd)
cd $HOME/Documents/dotfiles

echo "Copying configs"
cp -r $HOME/.config/i3 .

echo "Copying aliases"
cp $HOME/.bash_aliases .bash_aliases

echo "Copying packages"
apt-mark showmanual > packages.list

echo "Coppying ppas"
apt-cache policy | grep http | awk '{print $2 $3}' | sort -u > ppa.list

#echo "Copying variety"
#cp -r $HOME/.config/variety ./

echo "Copying gtk*"
cp -r $HOME/.config/gtk* ./

echo "Copying scripts"
cp $HOME/Pictures/wallpaper/*.sh ./

echo "Copying rofi"
cp $HOME/.local/share/rofi/themes ./rofi/themes

echo "COMITTING"
git add .
git commit . -m "$(date)"
git push origin master

cd $lwd
