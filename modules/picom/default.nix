{ lib, config, pkgs, ... }:

with lib;
let cfg = config.module.picom;

in {
  options.module.picom = { enable = mkEnableOption "picom"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ picom ];

    services.picom = {
      enable = true;
      vSync = true;
      shadow = true;
      shadowOpacity = 0.9;

      shadowExclude = [
        "name = 'Notification'"
        "class_g = 'Conky'"
        "class_g ?= 'Notify-osd'"
        "class_g = 'Cairo-clock'"
        "_GTK_FRAME_EXTENTS@:c"
        "!focused && !floating"
        "_NET_WM_NAME@:s *= 'Android Emulator'"
      ];

      settings.blur = { shadow-radius = 12; };
    };
  };
}
