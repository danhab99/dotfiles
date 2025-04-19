{ pkgs, ... }:
let
  customBusybox = pkgs.busybox.overrideAttrs (oldAttrs: rec {
    postInstall = ''
      ${oldAttrs.postInstall or ""}
      # Remove the reboot symlink if it exists
      rm -f $out/bin/reboot
      rm -f $out/bin/host*
    '';
  });
in
{
  environment.systemPackages = with pkgs; [
    # minio-client
    # mongodb-compass
    # mongodb-tools
    # neovim
    # ngrok
    # pamixer
    # pkgsi686Linux.gperftools
    # python312Packages.pip
    acpi
    alsa-utils
    arandr
    archivemount
    argc
    astyle
    autorandr
    base16-schemes
    bat
    brave
    curl
    customBusybox
    dbeaver-bin
    entr
    ffmpeg
    file
    flameshot
    gimp
    glances
    gnumake
    gnutar
    gparted
    gzip
    lm_sensors
    nmap
    nnn
    nodejs
    obs-studio
    obsidian
    oneko
    openssl
    pamixer
    s3cmd
    scdl
    seahorse
    sshfs
    thunderbird
    unzip
    upower
    usbutils
    vim-full
    vlc
    vscode
    webcamoid
    wget
    yai
    yt-dlp
    zip
  ];
}
