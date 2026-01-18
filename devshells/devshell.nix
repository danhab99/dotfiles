{ name, versions }:
inputs@{ pkgs, lib, ... }:

let
  mkShellForVersion =
    version: body:
    let
      shellName = if version == "" then name else "${name}-${version}";
      env = body.env or { };
    in
    pkgs.mkShell (
      env
      // {
        name = shellName;
        buildInputs = body.packages;
        shellHook = body.shellHook or "";
      }
    );

  mkTemplateForVersion =
    version: body:
    let
      indent = builtins.concatStringsSep "\n" (map (line: "  " + line) (builtins.split "\n" str));

      shellName = if version == "" then name else "${name}-${version}";
      env = body.env or { };
      packageNames = map (pkg: pkg.name) body.packages;

      flakenix =
        ''
          {
            description = "Devshell for ${shellsName} work";

            inputs = {
              nixpkgs.url = "github:NixOS/nixpkgs";
              flake-utils.url = "github:numtide/flake-utils";
            };

            outputs = { self, nixpkgs, flake-utils }:
              flake-utils.lib.eachSystem flake-utils.lib.defaultSystems (system:
                let
                  pkgs = import nixpkgs {
                    inherit system;
                    config.allowUnfree = true;
                  };
                  lib = pkgs.lib;

                in {
                  devShells = {
                    default = pkgs.mkShell {
                      packages = with pkgs; [
                        gnumake
                        # ...
                        ${
                          (indent {
                            str = builtins.concatStringsSep "\n" packageNames;
                            levels = 7;
                          })
                        }
                      ];

                      shellHook = ''
                        ${
                          (indent {
                            str = body.shellHook;
                            levels = 7;
                          })
                        }
                        '';
                      };
                    };
                  });
            }
          '';
    in
    pkgs.mkDerivation {
      name = "template-${shellName}";
      pname = "template-${name}";
      version = version;

      buildInputs = body.packages;

      buildPhase = ''
        mkdir -p $out
        echo ${flakenix} > $out/flake.nix
      '';
    };

in
{
  shells = lib.attrsets.mapAttrs mkShellForVersion (versions inputs);
  templates = lib.attrsets.mapAttrs mkShellForVersion (versions inputs);
}
