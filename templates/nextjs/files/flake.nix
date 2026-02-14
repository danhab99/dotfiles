{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        lib = pkgs.lib;

      in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              gnumake
              nodejs_22
              yarn
              prettierd
            ];

            shellHook = ''
              zsh
            '';
          };
        };
      }
    );
}
