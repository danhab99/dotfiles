import ../module.nix {
  name = "essential-packages";

  output =
    { pkgs, ... }:
    let
      customBusybox = pkgs.busybox.overrideAttrs (oldAttrs: rec {
        postInstall = ''
          ${oldAttrs.postInstall or ""}
          # Remove the reboot symlink if it exists
          rm -f $out/bin/reboot
          rm -f $out/bin/host*
          rm -f $out/bin/lspci
        '';
      });
    in
    {
      packages = with pkgs; [
        acpi
        archivemount
        cachix
        curl
        customBusybox
        entr
        ffmpeg
        file
        gnumake
        gnutar
        gzip
        jq
        nmap
        unzip
        wget
        zip
        gparted
        lm_sensors
        parted
        pciutils
        upower
        usbutils
      ];
    };
}
