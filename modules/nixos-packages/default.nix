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
          rm -f $out/bin/lspci
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
        gh-copilot
        gimp
        github-copilot-cli
        gparted
        kubectl
        lm_sensors
        nettools
        obsidian
        parted
        pciutils
        postgresql
        seahorse
        tree
        unixODBCDrivers.msodbcsql17
        upower
        usbutils
        vlc
        webcamoid
      ];
    };
}
