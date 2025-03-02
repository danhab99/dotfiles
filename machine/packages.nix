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
  corepack_22
  customBusybox
  docker
  docker-compose
  docker-credential-helpers
  file
  fontforge
  git
  gnumake
  gnutar
  gparted
  gradle
  gzip
  kdePackages.kcalc
  killall
  kubectl
  lazygit
  libratbag
  linuxKernel.packages.linux_zen.nvidia_x11
  lm_sensors
  maven
  minio-client
  mongodb-compass
  mongodb-tools
  nemo
  neovim
  nix-ld
  nodePackages.prisma
  nodejs_22
  nvtopPackages.full
  openssl
  pamixer
  pavucontrol
  pkgsi686Linux.gperftools
  pnpm
  postgresql_16
  prettierd
  prisma-engines
  pulseaudioFull
  python3
  rofi
  rxvt-unicode
  sutils
  sysstat
  terraform
  terraform-lsp
  unzip
  usbutils
  wget
  xclip
  xdotool
  xorg.xev
  xpad
  xsel
  yai
  yarn
  zip
  zoxide
]
