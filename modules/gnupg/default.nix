{ lib, config, ... }:

with lib;
let cfg = config.module.gnupg;

in {
  options.modules.gnupg = { enable = mkEnableOption "gnupg"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ gnupg pinentry-curses ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      settings = {
        default-cache-ttl = "10000000";
        max-cache-ttl = "10000000";
      };
      pinentryPackage = pkgs.pinentry-curses;
    };
  };
}
