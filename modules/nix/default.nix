import ../_module.nix {
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
          experimental-features = [ "nix-command" "flakes" ];
          trusted-users = [ "root" "dan" ];

          allowed-users = [ "dan" ];
          require-sigs = false;
        };

        nix.distributedBuilds = cfg.remoteBuild;
        nix.buildMachines = [
          {
            hostName = "desktop-nix";
            sshUser = "dan";
            # FIX: Bypass the systemd multiplexer and silence status messages
            systems = [ "x86_64-linux" "aarch64-linux" ];
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
