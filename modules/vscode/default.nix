import ../module.nix {
  name = "vscode";

  output =
    { pkgs, ... }:
    {
      homeManager = {
        programs.vscode = {
          enable = true;
          package = pkgs.vscode-fhs; # or pkgs.vscodium

          mutableExtensionsDir = true;

          profiles.default = {
            # enableMCPIntergration = true;
            # enableUpdateCheck = false;
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
}
