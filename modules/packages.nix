{ pkgs, lib, config, ... }:
let
  customBusybox = pkgs.busybox.overrideAttrs (oldAttrs: rec {
    postInstall = ''
      ${oldAttrs.postInstall or ""}
      # Remove the reboot symlink if it exists
      rm -f $out/bin/reboot
      rm -f $out/bin/host*
    '';
  });

  # ---

  packages = with pkgs; {
    "all" = [
      archivemount
      argc
      curl
      entr
      ffmpeg
      file
      glances
      gnumake
      gnutar
      gzip
      jq
      nmap
      nodejs
      openssl
      playerctl
      s3cmd
      scdl
      sshfs
      unzip
      wget
      yai
      yt-dlp
      zip
    ];

    "nixos" = [
      acpi
      audacity
      brave
      dbeaver-bin
      customBusybox
      firefox
      gimp
      gparted
      kubectl
      lm_sensors
      obsidian
      postgresql
      seahorse
      unixODBCDrivers.msodbcsql17
      upower
      usbutils
      vlc
      vscode
      webcamoid
    ];

    "droid" = [
      openssh
    ];
  };

  # ---

  getPackages = name: packages."all" ++ packages."${name}";
  groups = builtins.filter (s: s != "all") (builtins.attrNames packages);

  enabledPackages = builtins.mapAttrs (name: option: (if option.enable then getPackages name else [ ])) (config.packages);
in
{
  options.packages = builtins.listToAttrs (
    map
      (group: {
        name = group;
        value = {
          enable = lib.mkEnableOption group;
        };
      })
      groups
  );

  config.environment.packages = builtins.foldl' (x: y: x ++ y) [ ] (builtins.attrValues enabledPackages);
}
