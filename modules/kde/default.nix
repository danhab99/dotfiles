# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.kde;

in {
  options.modules.kde = { enable = mkEnableOption "kde"; };
  config =
    mkIf cfg.enable { services.desktopManager = { plasma6.enable = true; }; };
}
