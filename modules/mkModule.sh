# Check if the directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$1"

# Generate the Nix template and write it to the file
cat <<EOF > "$1/default.nix"
# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.$1;

in {
  options.modules.$1 = { enable = mkEnableOption "$1"; };
  config = mkIf cfg.enable { 
    home.packages = with pkgs; [ 
      # ...
    ];

    home.file = [ 
      # ...
    ];

    # ...
  };
}
EOF

echo "Module generated at $1/default.nix"
