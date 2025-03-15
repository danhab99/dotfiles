# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.part.gnupg;

in {
  options.part.gnupg = { enable = mkEnableOption "gnupg"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

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
