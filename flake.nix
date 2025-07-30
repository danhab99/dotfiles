{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs_for_xpad.url =  "github:nixos/nixpkgs/910796cabe436259a29a72e8d3f5e180fc6dfacc"; 
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, nixpkgs_for_xpad, ... }@inputs:
    let
      inherit (self) outputs;

      mkNix = hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = { 
            inherit inputs outputs;
            nixpkgs_for_xpad = import nixpkgs_for_xpad { system = "x86_64-linux"; };
          };
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
