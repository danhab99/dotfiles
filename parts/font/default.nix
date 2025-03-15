# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.font;

in {
  options.modules.font = { enable = mkEnableOption "font"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

    fonts.packages = with pkgs.nerd-fonts; [ fira-code iosevka mononoki ];
  };
}
