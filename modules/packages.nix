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
    acpi
    alsa-utils
    arandr
    archivemount
    argc
    astyle
    autorandr
    bat
    brave
    curl
    customBusybox
    dbeaver-bin
    entr
    ffmpeg
    file
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
    obsidian
    openssl
    pamixer
    s3cmd
    scdl
    seahorse
    sshfs
    unzip
    upower
    usbutils
    vlc
    vscode
    webcamoid
    wget
    yai
    yt-dlp
    zip
  ];
}
