# Unified module wrapper (Pure Flake Outputs Version)
#
# Three modes (determined by which argument is provided):
#
# 1. Regular module (output):
#   import ../output.nix inputs {
#     name = "my-module";
#     output = { pkgs, cfg, ... }: {
#       nixos = { ... };
#       homeManager = { ... };
#       packages = [ pkgs.hello ];
#     };
#   }
#
# 2. Devshell (devshells):
#   import ../output.nix inputs {
#     name = "go";
#     devshells = { pkgs, ... }: { "" = { packages = [ pkgs.go ]; }; };
#   }
#
# 3. Template (template):
#   import ../output.nix inputs {
#     name = "blank";
#     description = "blank nix shell";
#     template = ./_files;
#   }
inputs:
{ name # Passed directly from your flake now ,
, options ? { ... }: { }
, output ? null
, devshells ? null
, template ? null
, description ? name
, templateWelcome ? null
, lib ? inputs.nixpkgs.lib
}:

let
  # ── Devshell mode ──────────────────────────────────────────────
  devshellOutputs =
    if devshells != null then
      let
        mkName = version: if version == "" then name else "${name}-${version}";

        # Instead of 'perSystem', we dynamically construct a system-mapped attrset
        # supporting standard default systems.
        systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

        mkShells =
          builtins.listToAttrs (map
            (system: {
              name = system;
              value =
                let
                  pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
                  shellInputs = inputs // { inherit pkgs lib; };
                  versionSet = devshells shellInputs;
                in
                lib.attrsets.mapAttrs'
                  (version: body: {
                    name = mkName version;
                    value = pkgs.mkShell (
                      body.env or { } // {
                        name = mkName version;
                        buildInputs = body.packages;
                        shellHook = body.shellHook or "";
                      }
                    );
                  })
                  versionSet;
            })
            systems);

        mkTemplates =
          let
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            shellInputs = inputs // { inherit pkgs lib; };
            versionSet = devshells shellInputs;

            serializeEnv =
              env:
              lib.concatStringsSep "\n" (
                lib.mapAttrsToList (
                  k: v:
                  "            ${k} = \"${lib.replaceStrings [ "\"" ] [ "\\\"" ] (toString v)}\";"
                ) env
              );

            serializeShellHook =
              hook:
              if hook == "" then
                ""
              else
                "            shellHook = ''\n${lib.replaceStrings [ "''" ] [ "'''\\'''" ] hook}\n            '';\n";
          in
          lib.attrsets.mapAttrs'
            (version: body: {
              name = mkName version;
              value =
                let
                  packageNames =
                    body.templatePackageNames or (map (pkg: pkg.pname) body.packages);
                  env = body.env or { };
                  shellHook = body.shellHook or "";
                  envBlock =
                    if env == { } then
                      ""
                    else
                      ''
                        env = {
                        ${serializeEnv env}
                        };
                      '';
                in
                {
                  description = "${mkName version} template";
                  path = pkgs.stdenv.mkDerivation {
                    pname = "devshell-template-${mkName version}";
                    inherit version;
                    dontUnpack = true;
                    installPhase = ''
                      mkdir -p $out
                      cat > $out/flake.nix <<EOF
                      {
                        description = "${mkName version} template";
                        inputs = {
                          nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
                                  ${builtins.concatStringsSep "\n                                  " packageNames}
                                ];
                      ${envBlock}${serializeShellHook shellHook}
                              };
                            }
                          );
                      }
                      EOF
                    '';
                  };
                };
            })
            versionSet;
      in
      {
        devShells = mkShells;
        templates = mkTemplates;
      }
    else
      { };

  # ── Template mode ──────────────────────────────────────────────
  templateOutputs =
    if template != null then
      {
        templates.${name} = {
          inherit description;
          path = template;
        } // (if templateWelcome != null then { inherit templateWelcome; } else { });
      }
    else
      { };

  # ── Regular module mode ────────────────────────────────────────
  regularOutputs =
    if output != null then
      let
        getOpt = f: f { inherit lib; };
        moduleOptions = getOpt options;

        mkNixosModule =
          { lib, config, pkgs, ... }:
          let
            cfg = config.module.${name};
            out = output (inputs // { inherit pkgs lib config cfg; });

            nixosCfg = out.nixos or { };
            droidCfg = out.droid or { };
            packages = out.packages or [ ];
            hm = out.homeManager or { };

            homeConfig =
              let
                pairs = builtins.map
                  (user: {
                    name = user;
                    value = hm;
                  })
                  cfg.forUsers;
              in
              builtins.listToAttrs pairs;
            homeManagerConfig = lib.setAttrByPath (lib.splitString "." "home-manager.users") homeConfig;
          in
          {
            options.module.${name} =
              moduleOptions
              // {
                enable = lib.mkEnableOption name;
                forUsers = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ "dan" ];
                };
              };

            config = lib.mkIf cfg.enable (
              nixosCfg
              // droidCfg
              // {
                environment.systemPackages = packages;
              }
              // homeManagerConfig
            );
          };

        mkHmModule =
          { lib, config, pkgs, ... }:
          let
            cfg = config.module.${name};
            out = output (inputs // { inherit pkgs lib config cfg; });

            hm = out.homeManager or { };
            packages = out.packages or [ ];
          in
          {
            options.module.${name} =
              moduleOptions
              // {
                enable = lib.mkEnableOption name;
              };

            config = lib.mkIf cfg.enable (
              hm
              // {
                home.packages = packages;
              }
            );
          };
      in
      {
        nixosModules.subflake = mkNixosModule;
        homeManagerModules.subflake = mkHmModule;
      }
    else
      { };
in

# Simply merge standard flat flake outputs together
devshellOutputs // templateOutputs // regularOutputs
