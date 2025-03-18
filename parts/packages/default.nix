# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.part.packages;

in {
  options.part.packages = { enable = mkEnableOption "packages"; };
  config = mkIf cfg.enable {
    environment.systemPackages = let
      customBusybox = pkgs.busybox.overrideAttrs (oldAttrs: rec {
        postInstall = ''
          ${oldAttrs.postInstall or ""}
          # Remove the reboot symlink if it exists
          rm -f $out/bin/reboot
          rm -f $out/bin/host*
        '';
      });
    in with pkgs; [
      alsa-utils
      customBusybox
      file
      gnumake
      gnutar
      gparted
      gzip
      lazygit
      linuxKernel.packages.linux_zen.nvidia_x11
      lm_sensors
      nemo
      nvtopPackages.full
      openssl
      # pamixer
      pavucontrol
      # pkgsi686Linux.gperftools
      pulseaudioFull
      rofi
      unzip
      usbutils
      wget
      yai
      yarn
      zip
    ];

    # ...
  };
}
