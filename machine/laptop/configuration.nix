{ pkgs, ... }:
let
  mkMachine = import ../mkMachine.nix { inherit pkgs; };
in
{
  imports = [ ../../parts/default.nix ];

  config = mkMachine { hostName = "remotestation"; } {
    part = {
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
  };
}
