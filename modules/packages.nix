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
    arandr
    archivemount
    argc
    astyle
    audacity
    autorandr
    bat
    brave
    curl
    customBusybox
    dbeaver-bin
    entr
    ffmpeg
    file
    firefox
    gimp
    glances
    gnumake
    gnutar
    gparted
    gzip
    jq
    kubectl
    lm_sensors
    nmap
    nnn
    nodejs
    obsidian
    openssl
    playerctl
    postgresql
    s3cmd
    scdl
    seahorse
    sshfs
    unixODBCDrivers.msodbcsql17
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
