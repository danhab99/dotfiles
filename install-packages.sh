echo "### Installing PACMAN packages ###"

pacman -Syyy

cat pacman.list | while read line
do
  echo "### Installing $line ###"
  L=$(echo $line | grep -o "^\S*")
  yes | sudo pacman -S "$L"
done
