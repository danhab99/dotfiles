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
        python3
        s3cmd
        scdl
        sshfs
        unzip
        yai
        yt-dlp
        zip
      ];
    };
}
