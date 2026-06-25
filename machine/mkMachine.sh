# Check if the directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Create the target directory if it doesn't exist
mkdir -p "$1"

# Start the configuration.nix file
cat <<EOF > "$1/flake.nix"
{
  description = "$1 NixOS configuration";

  inputs = {
    # === Modules flake (provides all shared inputs) ===

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

EOF

../listinputs.sh "$1" >> "$1/flake.nix"

cat << EOF >> "$1/flake.nix"
  };

  outputs = inputs: {
    nixosConfigurations.subflake = import ../output.nix inputs {
      hardware-configuration = ./hardware-configuration.nix;

      hostCfg = {
        name = "workstation";
        system = "x86_64-linux";

        users = {
EOF

# List all directories in ../modules and add them as <name>.enable = true;
for dir in ../users/*/; do
  name=$(basename "$dir")
  echo "          $name.enable = true;" >> "$1/flake.nix"
done

# Close the config block
cat <<EOF >> "$1/flake.nix"
        };

        module = {
EOF

# List all directories in ../users and add them as <name>.enable = true;
for dir in ../subflakes/*/; do
  name=$(basename "$dir")
  echo "          $name.enable = true;" >> "$1/flake.nix"
done

# Close the config block
cat <<EOF >> "$1/flake.nix"
        };
      };
    };
  };
}
EOF

cp ../flake.lock $1/flake.lock

cd $1 && nix flake show

echo "Machine configuration generated at $1/flake.nix"
