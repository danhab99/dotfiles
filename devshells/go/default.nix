import ../devshell.nix {
  name = "go";

  versions =
    inputs@{ self, pkgs, ... }:
    let
      mkNeovim = import ../mkNeovim.nix inputs;
    in
    {
      "" = {
        packages = with pkgs; [
          go
          gopls
          (mkNeovim {
            plugins = with pkgs.vimPlugins; [
              coc-go
            ];
            coc = {
              "languageserver" = {
                "go" = {
                  "command" = "gopls";
                  "rootPatterns" = [ "go.mod" ];
                  "filetypes" = [ "go" ];
                };
              };
            };
          })
        ];

        env = {
          GO_PATH = "${self.outPath}/.go";
        };
      };
    };
}
