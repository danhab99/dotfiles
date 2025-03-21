# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "secrets";

  output = { ... }: {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

    security.rtkit.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true; # Enable for TTY login
      sddm.enableGnomeKeyring = true;
    };

    services.gnome.gnome-keyring = { enable = true; };

    services.passSecretService.enable = true;
  };
}
