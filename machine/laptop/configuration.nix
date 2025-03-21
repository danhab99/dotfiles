{ pkgs, ... }:
let
  mkMachine = import ../mkMachine.nix { inherit pkgs; };
in
{
  imports = [ ../../modules/default.nix ];

  config = mkMachine { hostName = "laptop"; } {
    module = {
      appimage.enable = true;
      docker.enable = true;
      font.enable = true;
      fzf.enable = true;
      git.enable = true;
      gnupg.enable = true;
      i18n.enable = true;
      i3 = { enable = true; configFile = ./i3/config; };
      nix.enable = true;
      ollama = { enable = false; repoDir = "/bucket/ollama"; };
      packages.enable = true;
      picom.enable = true;
      pipewire.enable = true;
      printing.enable = true;
      ratbag.enable = false;
      rofi.enable = true;
      sddm.enable = true;
      secrets.enable = true;
      ssh.enable = true;
      steam.enable = false;
      threedtools.enable = false;
      timezone.enable = true;
      urxvt.enable = true;
      vim.enable = true;
      xorg.enable = true;
      xserver = { enable = true; videoDriver = "nvidia"; };
      zoxide.enable = true;
      zsh.enable = true;
    };
  };
}
