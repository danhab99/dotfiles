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
  description = "$1";
  path = ./files;
}
EOF

cp -r blank/files $1/

echo "Template generated at $1"
