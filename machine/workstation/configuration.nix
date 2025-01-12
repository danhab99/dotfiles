{ pkgs, ... }@inputs:

{
  imports = [
    ../../program/appimage.nix
    ../../program/clang.nix
    ../../program/gnupg.nix
    # ../../program/go.nix
    (import ../../program/i3.nix {
      inherit pkgs inputs;
      i3config = ./config.i3;
    })
    ../../program/java.nix
    ../../program/nixlang.nix
    ../../program/rust.nix
    ../../program/steam.nix
    ../../program/zsh.nix

    ../../service/secrets.nix
    ../../service/display_manager.nix
    ../../service/openssh.nix
    ../../service/pipewire.nix
    ../../service/printing.nix
    ../../service/ratbagd.nix
    ../../service/udev.nix
    ../../service/xserver.nix
  ];

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
