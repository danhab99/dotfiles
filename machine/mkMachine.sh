# Check if the directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$1"

# Generate the Nix template and write it to the file
cat <<EOF > "$1/configuration.nix"
{ pkgs, ... }:
let
  mkMachine = import ../mkMachine.nix { inherit pkgs; };
in
{
  imports = [ ../../parts/default.nix ];

  config = mkMachine { hostName = "$1"; } {
    part = {
      appimage.enable = true;
      docker.enable = true;
      font.enable = true;
      gnupg.enable = true;
      i18n.enable = true;
      i3.enable = true;
      nix.enable = true;
      packages.enable = true;
      pipewire.enable = true;
      printing.enable = true;
      ratbag.enable = true;
      sddm.enable = true;
      secrets.enable = true;
      ssh.enable = true;
      steam.enable = true;
      timezone.enable = true;
      xserver.enable = true;
      zsh.enable = true;
    };
  };
}
EOF

echo "Machine generated at $1/default.nix"
