{ name
, versions
,
}:
inputs@{ pkgs, lib, ... }:
lib.attrsets.mapAttrs
  (
    version: body:
    {
      shell = pkgs.mkShell
        (
          body.env or { }
          // {
            name = "${name}-${version}";
            buildInputs = body.packages;
            shellHook = body.shellHook or "";
          }
        );

      template =
        let
          packages = map (pkg: pkg.pname) body.packages;

        in
        {
          description = "${name}-${version} template";
          path = pkgs.stdenv.mkDerivation
            {
              pname = "devshell-template-${name}-${version}";
              inherit version;

              dontUnpack = true;

              installPhase = ''
                cat > $out/flake.nix <<EOF
                {
                  description = "${name}-${version} template";
                  inputs = {
                    nixpkgs.url = "github:NixOS/nixpkgs";
                    flake-utils.url = "github:numtide/flake-utils";
                  };

                  outputs =
                    {
                      self,
                      nixpkgs,
                      flake-utils,
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
                              just
                              ${builtins.concatStringsSep "\n" packages}
                            ];
                          };
                        };
                      }
                    );
                }
                EOF
              '';
            };
        };
    }
  )
  (versions inputs)
