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
            package = pkgs.symlinkJoin {
              name = "vscode-fhs-wrapped";
              paths = [ pkgs.vscode-fhs ];
              buildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/code --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}
              '';
            };

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
