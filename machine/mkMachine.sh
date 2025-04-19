# Check if the directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Create the target directory if it doesn't exist
mkdir -p "$1"

# Start the configuration.nix file
cat <<EOF > "$1/configuration.nix"
{ ... }:

{
  imports = [ ../../modules/default.nix ];

  config.module = {
EOF

# List all directories in ../modules and add them as <name>.enable = true;
for dir in ../modules/*/; do
  name=$(basename "$dir")
  echo "    $name.enable = true;" >> "$1/configuration.nix"
done

# Close the config block
cat <<EOF >> "$1/configuration.nix"
  };
}
EOF

echo "Machine configuration generated at $1/configuration.nix"
