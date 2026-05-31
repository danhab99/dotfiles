{
  description = "zoxide";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "zoxide";

    output =
      { ... }:
      {
        nixos = { };

        homeManager = {
          programs.zoxide = {
            enable = true;
            enableZshIntegration = true;
          };
        };
      };
  };
}
