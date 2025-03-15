# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.xserver;

in {
  options.modules.xserver = { enable = mkEnableOption "xserver"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

    services.xserver = {
      enable = true;
      displayManager.startx.enable = true; # Optional if using startx
      videoDrivers = [ "nvidia" ];

      xautolock.enable = false;
      desktopManager.xterm.enable = false;

      # Keyboard settings
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };
}
