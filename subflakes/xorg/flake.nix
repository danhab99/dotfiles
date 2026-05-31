{
  description = "xorg";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "xorg";

    options = { lib }: with lib; {
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
          xbacklight
          xev
          xf86-input-evdev
          xsel
          arandr
          xrandr
          xorg-server
          displaylink
        ];

        nixos = {
          services.xserver = {
            enable = true;
            displayManager.startx.enable = true;
            videoDrivers = cfg.videoDrivers;

            xautolock.enable = false;
            desktopManager.xterm.enable = false;

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

            xkb = {
              model = "thinkpad";
              layout = "us";
              variant = "";
            };
          };

          services.libinput = {
            enable = true;
            mouse.middleEmulation = false;
          };

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
  };
}
