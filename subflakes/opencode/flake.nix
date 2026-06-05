{
  description = "opencode";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "opencode";

    options = { lib, ... }: with lib; {

    };

    output = { pkgs, ... }: {
      packages = with pkgs; [
        opencode
      ];

      homeManager = {
        home.file = {
          ".config/opencode/AGENTS.md" = {
            source = ./files/AGENTS.md;
          };
        };
      };

      droid = {

      };
    };

    template = ./files;
  };
}
