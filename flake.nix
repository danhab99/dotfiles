{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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
