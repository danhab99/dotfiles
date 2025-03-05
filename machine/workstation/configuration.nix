{ pkgs, ... }:

{
  imports = [ ./xserver.nix ];

  environment.systemPackages = with pkgs; [ gnome-keyring libsecret seahorse libratbag ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      false; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall =
      false; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  security.pam.services = {
    login.enableGnomeKeyring = true; # Enable for TTY login
    sddm.enableGnomeKeyring = true;
  };

  services.dbus.enable = true;

  services.displayManager = {
    sddm.enable = true;
    # defaultSession = "none+i3";
  };

  services.gnome.gnome-keyring = { enable = true; };

  services.openssh = {
    enable = true;
    allowSFTP = true;
    authorizedKeysInHomedir = true;
    settings.PasswordAuthentication = false;
  };

  services.passSecretService.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire = {
      "99-disable-bell" = {
        "context.properties" = { "module.x11.bell" = false; };
      };
    };
  };

  services.printing.enable = true;

  services.ratbagd = { enable = true; };
}
