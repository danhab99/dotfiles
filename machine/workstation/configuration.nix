{ pkgs, ... }@inputs:

{
  imports = [
    ../../programs/gnupg.nix
    ../../programs/java.nix
    ../../programs/steam.nix

    ../../services/display_manager.nix
    ../../services/openssh.nix
    ../../services/pipewire.nix
    ../../services/printing.nix
    ../../services/ratbagd.nix
    ../../services/udev.nix
    (import ../../services/xserver.nix {
      inherit pkgs inputs;
      i3config = ./config.i3;
    })
  ];

  programs.zsh.enable = true;

  networking = {
    hostName = "workstation";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 22 ];
      enable = true;
    };
  };

  users.users.dan = {
    isNormalUser = true;
    description = "dan";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
    shell = pkgs.zsh;
  };

  systemd = import ./systemd.nix { inherit pkgs inputs; };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
