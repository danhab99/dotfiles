{ pkgs }:
let
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
  arandr
  astyle
  autorandr
  base16-schemes
  customBusybox
  file
  fontforge
  gnumake
  gnutar
  gparted
  gzip
  kdePackages.kcalc
  killall
  kubectl
  linuxKernel.packages.linux_zen.nvidia_x11
  lm_sensors
  maven
  minio-client
  mongodb-compass
  mongodb-tools
  nemo
  neovim
  nix-ld
  nvtopPackages.full
  openssl
  pamixer
  pavucontrol
  pkgsi686Linux.gperftools
  pulseaudioFull
  rofi
  sutils
  sysstat
  unzip
  usbutils
  wget
  xclip
  xdotool
  xorg.xev
  xpad
  xsel
  yai
  zip
]
