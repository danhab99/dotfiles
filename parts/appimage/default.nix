# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.part.appimage;

in {
  options.part.appimage = { enable = mkEnableOption "appimage"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
