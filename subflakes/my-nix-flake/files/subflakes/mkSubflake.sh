# Check if the directory is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

mkdir -p "$1"
mkdir -p "$1/files"

cat <<EOF > "$1/flake.nix"
{
  description = "$1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "$1";

    options = { lib, ... }: with lib; {

    };

    output = { pkgs, ... }: {
      packages = with pkgs; [

      ];

      nixos = { 

      };

      homeManager = {

      };

      droid = {

      };
    };

    devshells = { pkgs, ... }: {
      default = {

      };
    };

    template = ./files;
    templateWelcome = "";
  };
}
EOF

cp ../flake.lock $1
