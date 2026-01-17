import ../devshell.nix {
  name = "python";

  versions = { pkgs, ... }: {
    "313" = {
      packages = with pkgs; [
        gnumake
        python313
        python313Packages.requests
        python313Packages.pypandoc
        python313Packages.toml
      ];
    };
  };
}
