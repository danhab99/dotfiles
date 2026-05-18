import ../_devshell.nix {
  name = "default";

  versions =
    { pkgs, ... }:
    {
      "" = {
        packages = with pkgs; [
          cachix
          containerd
          git
          just
          just
          nixd
          nixpkgs-fmt
        ];
      };
    };
}
