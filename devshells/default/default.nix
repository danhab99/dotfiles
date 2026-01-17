import ../devshell.nix
{
  name = "default";

  versions = { pkgs, ... }: {
    d = {
      packages = with pkgs; [
        git
        nixpkgs-fmt
        nixd
        gnumake
        containerd
        oci-cli
        cachix
      ];
    };
  };
}
