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
        cachix
        curl
        customBusybox
        entr
        ffmpeg
        file
        makefile
        just
        gnutar
        gzip
        jq
        nmap
        wget
        upower
        unzip
        zip
      ];
    };
}
