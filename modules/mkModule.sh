# Check if the directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$1"

# Generate the Nix template and write it to the file
cat <<EOF > "$1/default.nix"
import ../module.nix
{
  name = "$1";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {

    };

    nixos = {

    };
  };
}

EOF

echo "Module generated at $1/default.nix"

# Start the default.nix file
cat <<EOF > default.nix
{ ... }:

{
  imports = [
EOF

# Loop through each directory in ./modules and add it as an import
for dir in ./*/; do
  name=$(basename "$dir")
  echo "    ./$name" >> default.nix
done

# Close the imports block
cat <<EOF >> default.nix
  ];
}
EOF

echo "default.nix generated successfully."
