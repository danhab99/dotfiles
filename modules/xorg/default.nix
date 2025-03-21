import ../module.nix {
  name = "xorg";

  options = { lib }: with lib; {
    videoDriver = mkOption { };
  };

  output = { pkgs, cfg, ... }: {
    packages = with pkgs; [
      xclip
      xdotool
      xorg.xev
      xpad
      xsel
    ];

    nixos = {
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

    homeManager = {
      # xresources.extraConfig = builtins.concatStringsSep "\n" [
      #   (builtins.readFile ./Xresources)
      #   (builtins.readFile ./Xdefaults)
      # ];
      home.file = {
        # ".Xdefaults" = {
        #   source = builtins.concatStringsSep "\n" [
        #     (builtins.readFile ./Xresources)
        #     (builtins.readFile ./Xdefaults)
        #   ];
        # };
        # # ".Xresources" = { source = ./Xresources; };
      };
    };
  };
}
