{
  inputs = {
    # === NixOS ===
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    openclaw.url = "github:openclaw/nix-openclaw";
    nur.url = "github:nix-community/NUR";
    nixos-cli.url = "github:nix-community/nixos-cli";

    # === My flakes ===
    dotnet_8_nixpkgs.url = "github:nixos/nixpkgs/04f1c8b4eab2d07d390015461d182dc5818f89c4";
    axelera-driver.url = "github:danhab99/axelera-driver/copilot/add-nix-flake-package";
    adirofi.url = "github:danhab99/rofi";
    ev-cmd.url = "github:danhab99/ev-cmd/main";
    logitech-g600-rs.url = "github:danhab99/logitech-g600-rs/main";
    duh.url = "github:danhab99/duh/main";
    grit.url = "github:danhab99/grit/main";
    # puppy.url = "path:/home/dan/Documents/go/src/puppy";
    # agent-office.url = "path:/home/dan/Documents/agent-office";

    # === uConsole ===
    nixos-uconsole = {
      url = "github:nixos-uconsole/nixos-uconsole/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # === Droid ===
    droid-nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    droid-home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "droid-nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/master";
      inputs.nixpkgs.follows = "droid-nixpkgs";
      inputs.home-manager.follows = "droid-home-manager";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, flake-parts, import-tree, home-manager, nix-on-droid, droid-nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, ... }: {

      # ── Declare module storage options ──────────────────────────────
      options.flake.modules =
        let
          inherit (inputs.nixpkgs) lib;
        in
        {
          nixos = lib.mkOption {
            type = lib.types.attrsOf lib.types.deferredModule;
            default = { };
            description = "NixOS deferred modules keyed by aspect name";
          };
          droid = lib.mkOption {
            type = lib.types.attrsOf lib.types.deferredModule;
            default = { };
            description = "Nix-on-Droid deferred modules keyed by aspect name";
          };
          homeManager = lib.mkOption {
            type = lib.types.attrsOf lib.types.deferredModule;
            default = { };
            description = "Home-manager deferred modules keyed by aspect name";
          };
        };

      options.flake.templates =
        let
          inherit (inputs.nixpkgs) lib;
        in
        lib.mkOption {
          type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
          default = { };
          description = "Flake templates, mergeable across modules";
        };

      # ── Import all modules via import-tree ──────────────────────────
      imports = [
        (import-tree ./modules)
      ];

      # ── Systems for perSystem (devshells, etc.) ─────────────────────
      config.systems = [ "x86_64-linux" "aarch64-linux" ];

      # ── Flake-level outputs ─────────────────────────────────────────
      config.flake = {
        # NixOS host configurations - built from dendritic modules
        nixosConfigurations =
          let
            # Collect all NixOS deferred modules as a list
            allNixosModules = builtins.attrValues config.flake.modules.nixos;

            mkHost = import ./machine/machine.nix {
              inherit inputs allNixosModules;
            };

            dir = builtins.readDir ./machine;
            names = builtins.attrNames dir;
            machines = builtins.filter (f: dir.${f} == "directory") names;
            pairs = builtins.map
              (machineName: {
                name = machineName;
                value = mkHost machineName;
              })
              machines;
          in
          builtins.listToAttrs pairs;

        # Nix-on-Droid
        nixOnDroidConfigurations.default =
          let
            system = "aarch64-linux";
            droidPkgs = import droid-nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            allDroidModules = builtins.attrValues config.flake.modules.droid;
          in
          nix-on-droid.lib.nixOnDroidConfiguration {
            extraSpecialArgs = {
              pkgs = droidPkgs;
            } // inputs;

            pkgs = droidPkgs;

            modules = [
              { imports = allDroidModules; }
              ./nix-on-droid.nix
            ];
          };

        # Home-manager modules export
        homeManagerModules.default = {
          imports = builtins.attrValues config.flake.modules.homeManager;
        };

        # Distributable flake-parts module — friends can import this
        flakeModules.default = { inputs, ... }:
          let
            inherit (inputs.nixpkgs) lib;
          in
          {
            options.flake.modules = {
              nixos = lib.mkOption {
                type = lib.types.attrsOf lib.types.deferredModule;
                default = { };
              };
              droid = lib.mkOption {
                type = lib.types.attrsOf lib.types.deferredModule;
                default = { };
              };
              homeManager = lib.mkOption {
                type = lib.types.attrsOf lib.types.deferredModule;
                default = { };
              };
            };
            options.flake.templates = lib.mkOption {
              type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
              default = { };
            };
            imports = [ (import-tree ./modules) ];
          };

        formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      };
    });
}
