# Devshell wrapper — returns a flake-parts module.
#
# Usage:
#   import ../_devshell.nix { name = "go"; versions = { pkgs, ... }: { "" = { packages = [...]; }; }; }
#
# Registers perSystem.devShells.<name>-<version> and flake.templates.<name>-<version>.

{ name
, versions
}:

{ inputs, lib, ... }:
{
  perSystem = { pkgs, system, ... }:
    let
      shellInputs = inputs // { inherit pkgs lib; };
      versionSet = versions shellInputs;

      mkName = version: if version == "" then name else "${name}-${version}";

      shells = lib.attrsets.mapAttrs' (version: body: {
        name = mkName version;
        value = pkgs.mkShell (
          body.env or {} // {
            name = mkName version;
            buildInputs = body.packages;
            shellHook = body.shellHook or "";
          }
        );
      }) versionSet;
    in
    { devShells = shells; };

  flake.templates =
    let
      # Use x86_64-linux pkgs for template derivation generation
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      shellInputs = inputs // { inherit pkgs lib; };
      versionSet = versions shellInputs;

      mkName = version: if version == "" then name else "${name}-${version}";

      templates = lib.attrsets.mapAttrs' (version: body: {
        name = mkName version;
        value = let
          packages = map (pkg: pkg.pname) body.packages;
        in {
          description = "${mkName version} template";
          path = pkgs.stdenv.mkDerivation {
            pname = "devshell-template-${mkName version}";
            inherit version;
            dontUnpack = true;
            installPhase = ''
              cat > $out/flake.nix <<EOF
              {
                description = "${mkName version} template";
                inputs = {
                  nixpkgs.url = "github:NixOS/nixpkgs";
                  flake-utils.url = "github:numtide/flake-utils";
                };
                outputs = { self, nixpkgs, flake-utils }:
                  flake-utils.lib.eachSystem flake-utils.lib.defaultSystems (system:
                    let
                      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
                    in {
                      devShells.default = pkgs.mkShell {
                        packages = with pkgs; [
                          just
                          ${builtins.concatStringsSep "\n" packages}
                        ];
                      };
                    }
                  );
              }
              EOF
            '';
          };
        };
      }) versionSet;
    in
    templates;
}
