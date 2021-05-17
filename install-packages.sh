echo "### Installing PACMAN packages ###"

pacman -Syyy

cat pacman.list | while read line
do
  echo "### Installing $line ###"
  L=$(echo $line | grep -o "^\S*")
  sudo pacman -S "$line"
done
