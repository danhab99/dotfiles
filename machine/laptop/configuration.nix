{ pkgs, ... }@inputs:

{
  imports = [
    ../../program/appimage.nix
    ../../program/clang.nix
    ../../program/gnupg.nix
    ../../program/go.nix
    ../../program/java.nix
    ../../program/nixlang.nix
    ../../program/rust.nix
    ../../program/steam.nix
    ../../program/zsh.nix
    (import ../../program/i3.nix {
      inherit pkgs inputs;
      i3config = ./config.i3;
    })

    ../../service/display_manager.nix
    ../../service/flipperzero.nix
    ../../service/kde.nix
    ../../service/ollama.nix
    ../../service/openssh.nix
    ../../service/pipewire.nix
    ../../service/printing.nix
    ../../service/ratbagd.nix
    ../../service/secrets.nix
    ../../service/udev.nix
    ../../service/xserver.nix
    ../../service/urxvt.nix
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
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "dialout" ];
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
