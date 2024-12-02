{ pkgs, ... }:

{
  enable = true;
  displayManager.startx.enable = true; # Optional if using startx
  videoDrivers = [ "nvidia" ];

  xautolock.enable = false;

  desktopManager.xterm.enable = false;

  windowManager.i3 = {
    enable = true;
    package = pkgs.i3-rounded;

    configFile = pkgs.writeTextFile {
      name = "i3config";
      text = let
        dir = ../../config/i3;
        files = builtins.attrNames (builtins.readDir dir);
        common = builtins.concatStringsSep "\n"
          (map (file: builtins.readFile "${dir}/${file}") files);
        local = builtins.readFile ./config.i3;
      in builtins.concatStringsSep "\n" [ common local ];
    };
  };

  desktopManager.plasma5.enable = true;

  xkb = {
    layout = "us";
    variant = "";
  };

  config = ''
  '';
}
