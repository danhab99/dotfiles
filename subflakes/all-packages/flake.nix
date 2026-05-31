{
  description = "all-packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "all-packages";

    output = { pkgs, ... }: {
      packages = with pkgs; [
        glances
        gparted
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
        unzip
        usbutils
        wget
        yai
        yt-dlp
      ];
    };
  };
}
