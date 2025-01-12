{ pkgs, ... }:

{
  services.gnome.gnome-keyring = {
    enable = true;
  };

  security.pam.services = {
    login.enableGnomeKeyring = true; # Enable for TTY login
    sddm.enableGnomeKeyring = true;
  };

  services.dbus.enable = true;

  services.passSecretService.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret
    seahorse
  ];
}
