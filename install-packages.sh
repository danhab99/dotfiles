#echo "Adding PPAs"
#apt-cache policy | grep http | awk '{print $2 $3}' | sort -u > /tmp/ppa.list

#for ppa in $(diff -u /tmp/ppa.list ppa.list | grep -Po "(?<=\+)http.*");
#do
#  echo "### Adding $ppa ###"
#  sudo add-apt-repository $ppa -y
#done

sudo apt update

echo "Installing packages"
apt-mark showmanual > /tmp/packages.list

for package in $(diff -u /tmp/packages.list packages.list | grep -Po "(?<=\+)[a-zA-Z].*");
do
  echo "### Installing $package ###"
  sudo apt install $package -y
done

#ls `npm root -g` > /tmp/npm.list

#for package in $(diff -u /tmp/npm.list npm.list | grep -Po "(?<=\+)[a-zA-Z].*");do
#  echo "### Installing npm $package ###"
#  sudo npm install -g $package
#done
