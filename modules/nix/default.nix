import ../module.nix {
  name = "nix";

  options = { lib }: with lib; {
    remoteBuild = mkEnableOption { };
  };

  output =
    { pkgs, lib, cfg, ... }:
    {

      packages = with pkgs; [
        nix-index
      ];

      nixos = {
        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          allowed-users = [ "dan" ];
          require-sigs = true;
        };

        nix.distributedBuilds = cfg.remoteBuild;
        nix.buildMachines = [
          {
            hostName = "desktop"; # IP or SSH alias
            sshUser = "dan";
            systems = [ "x86_64-linux" "aarch64-linux" ]; # Architectures it can handle
            maxJobs = 20;
            supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
            mandatoryFeatures = [ ];
          }
        ];

        nixpkgs.config.allowUnfree = true;
        nixpkgs.config.allowBroken = true;

        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
          gtk3
          glibc
          freetype
        ];
      };

      homeManager = { };
    };
}
