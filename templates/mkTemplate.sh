# Check if the directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$1"

# Generate the Nix template and write it to the file
cat <<EOF > "$1/default.nix"
{
  description = "";
  path = ./files;
}
EOF

cp -r blank/files $1/

echo "Module generated at $1"

# # Start the default.nix file
# cat <<EOF > default.nix
# [
# EOF

# # Loop through each directory in ./modules and add it as an import
# for dir in ./*/; do
#   name=$(basename "$dir")
#   echo "  ( import ./$name )" >> default.nix
# done

# # Close the imports block
# cat <<EOF >> default.nix
# ];
# EOF

# echo "default.nix generated successfully."
