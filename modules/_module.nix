# Dendritic module wrapper.
#
# Usage:
#   import ./_module.nix {
#     name = "ev-cmd";
#     requires = {
#       ev-cmd.url = "github:danhab99/ev-cmd/main";
#     };
#     output = { pkgs, ev-cmd, cfg, ... }: { ... };
#   }
#
# `requires` documents which flake inputs the module needs.
# Each key must exist in the top-level flake inputs.

{ name
, options ? { ... }: { }
, output
, requires ? {}
}:

let requiredInputNames = builtins.attrNames requires; in

# This is the flake-parts module function
{ inputs, ... }:
let
  # Resolve each required input from the top-level flake inputs.
  selectedInputs =
    builtins.listToAttrs
      (map (n: {
        name = n;
        value = inputs.${n} or (throw "Module '${name}' requires flake input '${n}' — add it to flake.nix inputs");
      }) requiredInputNames);
in
{
  # ── NixOS deferred module ──────────────────────────────────────────
  flake.modules.nixos.${name} =
    { lib, config, pkgs, ... }:
    let
      cfg = config.module.${name};

      # Call the user's output function with NixOS module args + declared inputs
      out = output ({ inherit pkgs lib config cfg; } // selectedInputs);

      nixos = out.nixos or { };
      packages = out.packages or [ ];
      homeManager = out.homeManager or { };

      getOpt = f: f { inherit lib; };
      moduleOptions = getOpt options;
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
        nixos
        // {
          environment.systemPackages = packages;
          home-manager.users =
            let
              pairs = builtins.map
                (user: {
                  name = user;
                  value = homeManager;
                })
                cfg.forUsers;
            in
            builtins.listToAttrs pairs;
        }
      );
    };

  # ── Droid deferred module ──────────────────────────────────────────
  flake.modules.droid.${name} =
    { lib, config, pkgs, ... }:
    let
      cfg = config.module.${name};
      out = output ({ inherit pkgs lib config cfg; } // selectedInputs);

      droid = out.droid or { };
      packages = out.packages or [ ];
      homeManager = out.homeManager or { };

      getOpt = f: f { inherit lib; };
      moduleOptions = getOpt options;
    in
    {
      options.module.${name} =
        moduleOptions
        // {
          enable = lib.mkEnableOption name;
        };

      config = lib.mkIf cfg.enable (
        droid
        // {
          environment.packages = packages;
          home-manager.config = homeManager;
        }
      );
    };

  # ── Home Manager standalone deferred module ────────────────────────
  flake.modules.homeManager.${name} =
    { lib, config, pkgs, ... }:
    let
      cfg = config.module.${name};
      out = output ({ inherit pkgs lib config cfg; } // selectedInputs);

      homeManager = out.homeManager or { };
      packages = out.packages or [ ];

      getOpt = f: f { inherit lib; };
      moduleOptions = getOpt options;
    in
    {
      options.module.${name} =
        moduleOptions
        // {
          enable = lib.mkEnableOption name;
        };

      config = lib.mkIf cfg.enable (
        homeManager
        // {
          home.packages = packages;
        }
      );
    };
}
