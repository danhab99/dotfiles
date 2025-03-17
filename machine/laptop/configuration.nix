{ pkgs, ... }:

{
  imports = [ ../../parts/default.nix ];

  config.part = {
    appimage.enable = true;
    docker.enable = true;
    font.enable = true;
    gnupg.enable = true;
    i18n.enable = true;
    i3.enable = true;
    nix.enable = true;
    packages.enable = true;
    pipewire.enable = true;
    printing.enable = false;
    ratbag.enable = false;
    sddm.enable = true;
    secrets.enable = true;
    ssh.enable = true;
    steam.enable = false;
    timezone.enable = true;
    xserver.enable = true;
    zsh.enable = true;
  };

  config = {
    users.users.dan = {
      isNormalUser = true;
      description = "dan";
      extraGroups = [ "networkmanager" "wheel" "docker" "input" "dialout" ];
      shell = pkgs.zsh;
    };

    networking = { 
      networkmanager.enable = true;
      hostName = "remotestation";
    };

    environment.localBinInPath = true;

    services.dbus.enable = true;
  };
}
