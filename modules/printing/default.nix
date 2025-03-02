# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.printing;

in {
  options.modules.printing = { enable = mkEnableOption "printing"; };
  config = mkIf cfg.enable { services.printing.enable = true; };
}
