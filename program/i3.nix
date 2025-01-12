{ pkgs, i3config, ... }:

{
  environment.systemPackages = with pkgs; [
    i3-rounded
    i3blocks
    i3status
    dmenu
    picom
    nitrogen
  ];

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-rounded;

    configFile = pkgs.writeTextFile {
      name = "i3config";
      text = let
        dir = ../config/i3;
        files = builtins.attrNames (builtins.readDir dir);
        common = builtins.concatStringsSep "\n"
          (map (file: builtins.readFile "${dir}/${file}") files);
        local = builtins.readFile i3config;
      in builtins.concatStringsSep "\n" [ common local ];
    };
  };

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
      "!focused"
      "_NET_WM_NAME@:s *= 'Android Emulator'"
    ];

    settings.blur = {
      shadow-radius = 12;
    };
  };
}
