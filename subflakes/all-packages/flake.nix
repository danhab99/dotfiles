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
        just
        gparted
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
        wget
      ];
    };
  };
}
