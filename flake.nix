{
  inputs = {
    # === NixOS ===
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # === My flakes ===
    dotnet_8_nixpkgs.url = "github:nixos/nixpkgs/04f1c8b4eab2d07d390015461d182dc5818f89c4";
    ev-cmd.url = "github:danhab99/ev-cmd/main";
    logitech-g600-rs.url = "github:danhab99/logitech-g600-rs/main";
    axelera-driver.url = "github:danhab99/axelera-driver/copilot/add-nix-flake-package";
    duh.url = "github:danhab99/duh/main";

    # === uConsole ===
    nixpkgs_for_uconsole.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-uconsole = {
      url = "github:nixos-uconsole/nixos-uconsole/master";
      # inputs.nixpkgs.follows = "nixpkgs_for_uconsole";
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
    inputs@{
      self,
      nixpkgs,
      home-manager,
      flake-utils,
      nix-on-droid,
      droid-nixpkgs,
      ...
    }:
    let
      inherit (self) outputs;

      mkNix = hostName: (import ./machine/${hostName}/configuration.nix) inputs;
    in
    {
      nixosConfigurations =
        let
          dir = builtins.readDir ./machine;
          names = builtins.attrNames dir;
          machines = builtins.filter (f: dir.${f} == "directory") names;
          pairs = builtins.map (machineName: {
            name = machineName;
            value = mkNix machineName;
          }) machines;
        in
        builtins.listToAttrs pairs;

      templates = import ./templates;

      nixOnDroidConfigurations.default =
        let
          system = "aarch64-linux";
          droidPkgs = import droid-nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        nix-on-droid.lib.nixOnDroidConfiguration {
          extraSpecialArgs = {
            pkgs = droidPkgs;
          }
          // inputs;

          pkgs = droidPkgs;

          modules = [
            ./nix-on-droid.nix
          ];
        };

      homeManagerModules.default = import ./modules/select.nix "homeManagerModule" inputs;

    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells = import ./devshells (
          inputs
          // {
            inherit pkgs;
            lib = pkgs.lib;
          }
        );
      }
    ));
}
