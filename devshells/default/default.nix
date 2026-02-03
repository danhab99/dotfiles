import ../devshell.nix {
  name = "default";

  versions =
    { pkgs, ... }:
    {
      "" = {
        packages = with pkgs; [
          cachix
          containerd
          git
          gnumake
          just
          nixd
          nixpkgs-fmt
        ];
      };
    };
}
