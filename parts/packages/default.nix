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
    ];

    # ...
  };
}
