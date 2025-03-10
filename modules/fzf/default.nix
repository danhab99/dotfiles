# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ lib, config, ... }:

with lib;
let cfg = config.modules.fzf;

in {
  options.modules.fzf = { enable = mkEnableOption "fzf"; };
  config = mkIf cfg.enable { 
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
