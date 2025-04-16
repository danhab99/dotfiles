import ../module.nix {
  name = "i3";

  options = { lib }: with lib; {
    configFile = mkOption {
      type = types.nullOr types.path;
      description = "Machine specific i3 config file";
      default = null;
    };
    i3blocksConfig = mkOption {
      type = types.path;
      description = "Machine specific i3blocks config file";
      default = ./i3blocks.conf;
    };
  };

  output = { pkgs, config, cfg, ... }: {
    packages = with pkgs; [
      i3-rounded
      i3blocks
      i3status
      dmenu
      picom
      nitrogen
      betterlockscreen
      nemo
      scrot
    ];

    nixos = {
      services.xserver.windowManager.i3 = {
        enable = true;
        package = pkgs.i3-rounded;
      };
    };

    homeManager = {
      xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3-rounded;

        config = (import ./config.nix { inherit pkgs cfg; });

        extraConfig = ''
          border_radius 8
          ${if cfg.configFile == null then "" else (builtins.readFile cfg.configFile)}
        '';
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
          "!focused && !floating"
          "_NET_WM_NAME@:s *= 'Android Emulator'"
        ];

        settings.blur = { shadow-radius = 12; };
      };

      home.file = {
        ".config/i3blocks-contrib" = {
          source = builtins.fetchGit {
            shallow = true;
            url = "https://github.com/vivien/i3blocks-contrib.git";
            rev = "9d66d81da8d521941a349da26457f4965fd6fcbd";
          };
          recursive = true;
        };

        # ".config/i3blocks.conf" = { source = ./i3blocks.conf; };
      };
    };
  };
}
