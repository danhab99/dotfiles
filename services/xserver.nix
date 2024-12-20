{ pkgs, i3config, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true; # Optional if using startx
    videoDrivers = [ "nvidia" ];

    xautolock.enable = false;
    desktopManager.xterm.enable = false;

    # X.org configuration
    config = ''
      Section "Device"
        Identifier "GPU0"
        Driver "nvidia"
        Option "AllowFlipping" "True"
        Option "TripleBuffer" "True"
        Option "ForceFullCompositionPipeline" "True"
      EndSection

      Section "Monitor"
          Identifier "HDMI-0"
          Option "PreferredMode" "1920x1080"
      EndSection

      Section "Monitor"
          Identifier "DP-5"
          Option "PreferredMode" "1920x1080"
          Option "RightOf" "HDMI-0"
      EndSection

      Section "Monitor"
          Identifier "DP-1"
          Option "PreferredMode" "1920x1080"
          Option "RightOf" "DP-5"
      EndSection

      Section "Screen"
          Identifier "Screen0"
          Device "GPU0"
          Option "metamodes" "HDMI-0: 1920x1080 +0+0, DP-5: 1920x1080 +1920+0, DP-1: 1920x1080 +3840+0"
          Option "AllowIndirectGLXProtocol" "True"
          Option "TripleBuffer" "True"
      EndSection
    '';

    # Keyboard settings
    xkb = {
      layout = "us";
      variant = "";
    };

    # Window Manager configuration
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-rounded;

      # i3 config file
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
  };
}