import ../devshell.nix {
  name = "default";

  versions =
    { pkgs, ... }:
    {
      "" = {
        packages = with pkgs; [
          git
          nixpkgs-fmt
          nixd
          gnumake
          containerd
          cachix
        ];
      };
    };
}
