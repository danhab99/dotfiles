{ lib, config, pkgs, ... }:

with lib;
let cfg = config.module.i3;

in {
  options.module.i3 = {
    enable = mkEnableOption "i3";
    configFile = mkOption "configFile";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      i3-rounded
      i3blocks
      i3status
      dmenu
      picom
      nitrogen
    ];

    services.displayManager = {
      sddm.enable = true;
      defaultSession = "none+i3";
    };

    services.xserver.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-rounded;

      configFile = pkgs.writeTextFile {
        name = "i3config";
        text = let
          dir = "./";
          files = builtins.attrNames (builtins.readDir dir);
          common = builtins.concatStringsSep "\n"
            (map (file: builtins.readFile "${dir}/${file}") files);
          local = builtins.readFile cfg.configFile;
        in builtins.concatStringsSep "\n" [ common local ];
      };
    };

    home.files = {
      ".config/i3blocks-contrib" = {
        source = builtins.fetchGit {
          shallow = true;
          url = "https://github.com/vivien/i3blocks-contrib.git";
          rev = "9d66d81da8d521941a349da26457f4965fd6fcbd";
        };
        recursive = true;
      };
      ".config/i3blocks.conf" = ./i3blocks.conf;
    };
  };
}
