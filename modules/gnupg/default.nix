{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gnupg;

in {
  options.modules.gnupg = { enable = mkEnableOption "gnupg"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ pass ];

    programs.gpg = {
      enable = true;
      mutableKeys = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 10000000;
      maxCacheTtl = 10000000;

      pinentryPackage = pkgs.pinentry-curses;
      enableZshIntegration = true;
    };
  };
}
