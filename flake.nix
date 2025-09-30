{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs_for_xpad.url = "github:nixos/nixpkgs/910796cabe436259a29a72e8d3f5e180fc6dfacc";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    droid-nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05-small";
    droid-home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows ="droid-nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "droid-nixpkgs";
      inputs.home-manager.follows = "droid-home-manager";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , home-manager
    , flake-utils
    , nixpkgs_for_xpad
    , nix-on-droid
    , droid-nixpkgs
    , ...
    }:
    let
      inherit (self) outputs;

      mkNix = hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            nixpkgs_for_xpad = import nixpkgs_for_xpad { system = "x86_64-linux"; };
          } // inputs;
          modules = [
            ./machine/${hostName}/configuration.nix
            ./machine/${hostName}/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
    in
    {
      nixosConfigurations =
        let
          dir = builtins.readDir ./machine;
          names = builtins.attrNames dir;
          machines = builtins.filter (f: dir.${f} == "directory") names;
          pairs = builtins.map (machineName: { name = machineName; value = mkNix machineName; }) machines;
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
          #  nixpkgs_for_xpad = import# nixpkgs_for_xpad { inherit system; };
            pkgs = droidPkgs;
          } // inputs;

          pkgs = droidPkgs;

          modules = [
            ./nix-on-droid.nix
          ];
        };
    } // (
      flake-utils.lib.eachSystem flake-utils.lib.allSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixpkgs-fmt
            nixd
            gnumake
            containerd
            oci-cli
          ];

          shellHook = ''
            zsh
          '';
        };
      })
    );
}
