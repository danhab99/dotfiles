{
  description = "fzf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "fzf";

    output =
      { ... }:
      {
        nixos = { };

        homeManager = {
          programs.fzf = {
            enable = true;
            enableZshIntegration = true;
          };
        };
      };
  };
}
