import ../module.nix {
  name = "all-packages";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        archivemount
        cachix
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
        python3
        s3cmd
        scdl
        sshfs
        unzip
        wget
        yai
        yt-dlp
        zip
      ];
    };
}
