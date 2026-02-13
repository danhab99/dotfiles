import ../devshell.nix {
  name = "python";

  versions =
    inputs@{ pkgs, ... }:
    let
      mkNeovim = import ../mkNeovim.nix inputs;
    in
    {
      "313" = {
        packages = with pkgs; [
          gnumake
          python313
          python313Packages.requests
          python313Packages.pypandoc
          python313Packages.toml
          (mkNeovim {
            plugins = with pkgs.vimPlugins; [
              coc-pyright
            ];
            coc = { };
          })
        ];
      };
    };
}
