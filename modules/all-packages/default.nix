import ../module.nix {
  name = "all-packages";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        glances
        nodejs
        openssl
        python3
        s3cmd
        scdl
        sshfs
        yai
        yt-dlp
      ];
    };
}
