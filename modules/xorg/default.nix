import ../module.nix {
  name = "xorg";

  options =
    { lib }:
    with lib;
    {
      videoDrivers = mkOption { };
      extraConfig = mkOption {
        type = types.str;
        default = "";
      };
      fontSize = mkOption {
        type = types.int;
      };
    };

  output =
    { pkgs, cfg, ... }:
    {
      packages = with pkgs; [
        xclip
        xdotool
        xorg.xbacklight
        xorg.xev
        xorg.xf86inputevdev
        xpad
        xsel
        arandr
        xorg.xrandr
        xorg.xorgserver
      ];

      nixos = {
        services.xserver = {
          enable = true;
          displayManager.startx.enable = true; # Optional if using startx
          videoDrivers = cfg.videoDrivers;

          xautolock.enable = false;
          desktopManager.xterm.enable = false;

          # Disable DPMS and screen blanking at X server level
          serverFlagsSection = ''
            Option "BlankTime" "0"
            Option "StandbyTime" "0"
            Option "SuspendTime" "0"
            Option "OffTime" "0"
          '';

          desktopManager.xfce = {
            enable = true;
            noDesktop = true;
            enableXfwm = false;
          };

          # Keyboard settings
          xkb = {
            model = "thinkpad";
            layout = "us";
            variant = "";
          };
        };

        services.libinput = {
          enable = true;
        };

        # Disable XFCE power manager to prevent it from managing DPMS
        services.xserver.desktopManager.xfce.enableScreensaver = false;
      };

      homeManager =
        let
          content = builtins.concatStringsSep "\n" [
            (builtins.readFile ./Xresources)
            (builtins.readFile ./Xdefaults)
            cfg.extraConfig
          ];

        in
        {
          xresources.extraConfig =
            builtins.replaceStrings [ "FONT_SIZE" ] [ (builtins.toString cfg.fontSize) ]
              content;
        };
    };
}
