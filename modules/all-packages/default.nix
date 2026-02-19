import ../module.nix {
  name = "all-packages";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        glances
        just
        killall
        nixfmt-tree
        nodejs
        openssl
        pciutils 
        powershell
        python3
        s3cmd
        scdl
        sshfs
        usbutils
        yai
        yt-dlp
      ];
    };
}
