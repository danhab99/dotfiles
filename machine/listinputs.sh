# List all directories in ../users and add them as <name>.enable = true;
for dir in ../subflakes/*/; do
  name=$(basename "$dir")
  echo "    $name.url = \"path:../../subflakes/$name\";"
done
