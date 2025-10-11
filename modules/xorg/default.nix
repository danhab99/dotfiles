import ../module.nix {
  name = "xorg";

  options = { lib }: with lib; {
    videoDrivers = mkOption { };
    extraConfig = mkOption {
      type = types.str;
      default = "";
    };
  };

  output = { pkgs, cfg, nixpkgs_for_xpad, ... }: {
    packages = with pkgs; [
      xclip
      xdotool
      xorg.xbacklight
      xorg.xev
      xorg.xf86inputevdev
      (import nixpkgs_for_xpad { system = "x86_64-linux"; }).xpad
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
    };

    homeManager = {
      xresources.extraConfig = builtins.concatStringsSep "\n" [
        (builtins.readFile ./Xresources)
        (builtins.readFile ./Xdefaults)
        cfg.extraConfig
      ];
    };
  };
}
