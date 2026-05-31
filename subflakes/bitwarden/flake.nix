{
  description = "bitwarden";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "bitwarden";

    output =
      { pkgs, ... }:
      {
        packages = with pkgs; [
          bitwarden-desktop
        ];

        homeManager = {
          programs.rbw = {
            enable = true;
            settings = {
              email = "dan.habot@gmail.com";
              pinentry = pkgs.pinentry-curses;
              base_url = null;
              identity_url = null;
            };
          };
        };

        nixos = { };
      };
  };
}
