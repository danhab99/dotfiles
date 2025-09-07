import ../module.nix
{
  name = "all-packages";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      archivemount
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
  };
}

