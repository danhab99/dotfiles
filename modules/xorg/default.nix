# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "xorg";

  output = { ... }: {
    packages = with pkgs; [
      xclip
      xdotool
      xorg.xev
      xpad
      xsel
    ];

    nixos = {
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

    homeManager = {
      home.file = {
        ".Xdefaults" = {
          source = ./Xdefaults;
        };
        # ".Xresources" = { source = ./Xresources; };
      };
    };
  };
}
