{
  description = "slack";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "slack";

    output =
      { pkgs, ... }:
      {
        packages = with pkgs; [
          slack-cli
          slack
          slack-term
        ];
      };
  };
}
