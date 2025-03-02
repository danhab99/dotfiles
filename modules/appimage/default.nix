{ lib, config, ... }:

with lib;
let cfg = config.modules.appimage;

in {
  options.modules.appimage = { enable = mkEnableOption "appimage"; };

  config = mkIf cfg.enable {
    # programs.appimage = {
    #   enable = true;
    #   binfmt = true;
    # };
  };
}
