# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.secrets;

in {
  options.modules.secrets = { enable = mkEnableOption "secrets"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

    security.pam.services = {
      login.enableGnomeKeyring = true; # Enable for TTY login
      sddm.enableGnomeKeyring = true;
    };

    services.gnome.gnome-keyring = { enable = true; };

    services.passSecretService.enable = true;
  };
}
