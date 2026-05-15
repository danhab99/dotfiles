# Helper function to create dendritic subflake modules
# This preserves the 3-plane pattern (nixos/homeManager/droid) for standalone subflakes
#
# Usage in a subflake:
#   mkModuleSubflake {
#     name = "git";
#     inputs = { inherit nixpkgs home-manager; };
#     options = { lib }: { /* option definitions */ };
#     output = { pkgs, config, lib, ... }: { nixos = {}; homeManager = {}; packages = []; };
#   }
#
# Returns outputs with:
#   - nixosModules.{name} and nixosModules.default
#   - homeManagerModules.{name} and homeManagerModules.default
#   - droidModules.{name} and droidModules.default (if droid-home-manager present)
#   - packages.{system}
#   - templates (if defined in output)

{ name
, options ? { ... }: { }
, output
, inputs
}:

{
  # -- NixOS module ------------------------------------------------
  nixosModules = {
    ${name} = { lib, config, pkgs, ... }:
      let
        cfg = config.module.${name};

        out = output ({
          inherit pkgs lib config cfg;
        } // inputs);

        nixosConfig = out.nixos or { };
        packages = out.packages or [ ];
        hmConfig = out.homeManager or { };

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
              default = [ ];
            };
          };

        config = lib.mkIf cfg.enable (
          nixosConfig
          // {
            environment.systemPackages = packages;
            home-manager.users =
              let
                pairs = builtins.map
                  (user: {
                    inherit user;
                    value = hmConfig;
                  })
                  cfg.forUsers;
              in
              builtins.listToAttrs pairs;
          }
        );
      };

    default = { lib, config, pkgs, ... }:
      let
        cfg = config.module.${name};

        out = output ({
          inherit pkgs lib config cfg;
        } // inputs);

        nixosConfig = out.nixos or { };
        packages = out.packages or [ ];
        hmConfig = out.homeManager or { };

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
              default = [ ];
            };
          };

        config = lib.mkIf cfg.enable (
          nixosConfig
          // {
            environment.systemPackages = packages;
            home-manager.users =
              let
                pairs = builtins.map
                  (user: {
                    inherit user;
                    value = hmConfig;
                  })
                  cfg.forUsers;
              in
              builtins.listToAttrs pairs;
          }
        );
      };
  };

  # -- Home Manager module ----------------------------------------
  homeManagerModules = {
    ${name} = { lib, config, pkgs, ... }:
      let
        cfg = config.module.${name};

        out = output ({
          inherit pkgs lib config cfg;
        } // inputs);

        hmConfig = out.homeManager or { };

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
              default = [ ];
            };
          };

        config = lib.mkIf cfg.enable hmConfig;
      };

    default = { lib, config, pkgs, ... }:
      let
        cfg = config.module.${name};

        out = output ({
          inherit pkgs lib config cfg;
        } // inputs);

        hmConfig = out.homeManager or { };

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
              default = [ ];
            };
          };

        config = lib.mkIf cfg.enable hmConfig;
      };
  };

  # -- Droid module (nix-on-droid) --------------------------------
  droidModules = {
    ${name} = { lib, config, pkgs, ... }:
      let
        cfg = config.module.${name};

        out = output ({
          inherit pkgs lib config cfg;
        } // inputs);

        droidConfig = out.droid or { };
        packages = out.packages or [ ];

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
              default = [ ];
            };
          };

        config = lib.mkIf cfg.enable (
          droidConfig
          // {
            environment.packages = packages;
          }
        );
      };

    default = { lib, config, pkgs, ... }:
      let
        cfg = config.module.${name};

        out = output ({
          inherit pkgs lib config cfg;
        } // inputs);

        droidConfig = out.droid or { };
        packages = out.packages or [ ];

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
              default = [ ];
            };
          };

        config = lib.mkIf cfg.enable (
          droidConfig
          // {
            environment.packages = packages;
          }
        );
      };
  };
}
# Helper function to create dendritic subflake modules
# This preserves the 3-plane pattern (nixos/homeManager/droid) for standalone subflakes
#
# Usage in a subflake:
#   mkModuleSubflake {
#     name = "git";
#     inputs = { inherit nixpkgs home-manager; };
#     options = { lib }: { /* option definitions */ };
#     output = { pkgs, config, lib, ... }: { nixos = {}; homeManager = {}; packages = []; };
#   }
#
# Returns outputs with:
#   - nixosModules.{name} and nixosModules.default
#   - homeManagerModules.{name} and homeManagerModules.default
#   - droidModules.{name} and droidModules.default (if droid-home-manager present)
#   - packages.{system}
#   - templates (if defined in output)

{ name
, options ? { ... }: { }
, output
, inputs
}:

let
  
  # Resolve each required input from provided inputs
