{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs_for_nixos_cli.url = "github:nixos/nixpkgs/e6cea36f83499eb4e9cd184c8a8e823296b50ad5";

    nixos-cli = {
      url = "github:water-sucks/nixos";
      # inputs.nixpkgs.follows = "nixpkgs_for_nixos_cli";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, nixos-cli, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkNix = hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            nixos-cli.nixosModules.nixos-cli
            (import ./machine/machine.nix { inherit hostName; })
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


      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          NIX_PATH = "nixpkgs=channel:nixos-unstable nil";
          NVIM_COC_LOG_LEVEL = "debug";
          NVIM_COC_LOG_FILE = "/tmp/coc.log";
          VIM_COC_LOG_LEVEL = "debug";
          VIM_COC_LOG_FILE = "/tmp/coc.log";

          buildInputs = with (pkgsFor system); [
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
      });
    };
}
