{
  description = "vscode";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "vscode";

    output =
      { pkgs, ... }:
      {
        homeManager = {
          programs.vscode = {
            enable = true;
            package = pkgs.vscode-fhs;

            mutableExtensionsDir = true;

            profiles.default = {
              extensions = with pkgs.vscode-extensions; [
                github.copilot
                jnoortheen.nix-ide
                ms-python.vscode-pylance
                vscodevim.vim
              ];
            };
          };
        };

        nixos = {

        };
      };
  };
}
