{
  description = "appimage";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "appimage";

    output =
      { pkgs, ... }:
      {
        nixos = {
          environment.systemPackages = with pkgs; [
            # ...
          ];

          programs.appimage = {
            enable = true;
            binfmt = true;
          };
        };

        homeManager = { };
      };
  };
}
