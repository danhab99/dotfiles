# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.part.xserver;

in {
  options.part.xserver = { 
    enable = mkEnableOption "xserver";
    videoDriver = mkOption {
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        xclip
        xdotool
        xorg.xev
        xpad
        xsel
      ];

    services.xserver = {
      enable = true;
      displayManager.startx.enable = true; # Optional if using startx
      videoDrivers = [ cfg.videoDriver ];

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
