import ../module.nix {
  name = "vscode";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [

      ];

      homeManager = {
        programs.vscode = {
          enable = true;
          package = pkgs.vscode-fhs; # or pkgs.vscodium
        };
      };

      nixos = {

      };
    };
}
