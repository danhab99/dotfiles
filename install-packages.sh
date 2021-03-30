echo "### Installing PACMAN packages ###"

pacman -Syyy

cat pacman.list | while read line
do
  echo "### Installing $line ###"
  sudo pacman -S "$line"
done
