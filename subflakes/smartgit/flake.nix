{
  description = "smartgit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "smartgit";

    options = { lib, ... }: with lib; {

    };

    output = { pkgs, ... }: {
      packages = [
        (pkgs.smartgit.overrideAttrs (old: rec {
          version = "24.1.2";
          src = pkgs.fetchurl {
            url = "https://www.syntevo.com/downloads/smartgit/smartgit-linux-${
              builtins.replaceStrings [ "." ] [ "_" ] version
            }.tar.gz";
            hash = "sha256-bPiPb/k5f9dRpwm4Wj+c2mhFhH9WOz2hzKeDfQLRLHQ=";
          };
        }))
      ];
    };
  };
}
