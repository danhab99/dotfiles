{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.gnupg;

in {
  options.modules.gnupg = { enable = mkEnableOption "gnupg"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gnupg pinentry-curses pass ];

    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      extraConfig = ''
        default-cache-ttl = 10000000
        max-cache-ttl = 10000000
      '';
      pinentryPackage = pkgs.pinentry-curses;
      enableZshIntegration = true;
    };
  };
}
