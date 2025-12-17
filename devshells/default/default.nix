{ pkgs, ... }: {
  name = "default";

  buildInputs = with pkgs; [
    git
    nixpkgs-fmt
    nixd
    gnumake
    containerd
    oci-cli
    cachix
  ];

  shellHook = ''
    zsh
  '';
}
