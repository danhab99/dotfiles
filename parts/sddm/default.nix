# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.sddm;

in {
  options.modules.sddm = { enable = mkEnableOption "sddm"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

    services.displayManager = {
      sddm.enable = true;
      defaultSession = "none+i3";
    };
  };
}
