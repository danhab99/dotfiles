import ../module.nix
{
  name = "nixos-packages";

  output = { pkgs, ... }:
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
      packages = with pkgs; [
        acpi
        audacity
        brave
        customBusybox
        dbeaver-bin
        firefox
        gimp
        gparted
        kubectl
        libreoffice
        lm_sensors
        nettools
        obsidian
        postgresql
        seahorse
        unixODBCDrivers.msodbcsql17
        upower
        usbutils
        vlc
        webcamoid
      ];
    };
}
