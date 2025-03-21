# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ lib, config, ... }:

in lib.mkModule {
  name = "fzf";
  output = { ... }: {
    homeManager = {
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
