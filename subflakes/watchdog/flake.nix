{
  description = "watchdog NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;
      timeout = 10;
      ts = builtins.toString;
    in
    mkModuleSubflake {
      name = "watchdog";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "watchdog module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            # Package list for this module
          ];

          nixos = {
            boot.kernelParams = [
              "efi_pstore.pstore_disable=0"
              "hardlockup_panic=1"
              "panic=${ts timeout}" # reboot 10 seconds after panic
              "reboot=bios"
              "softlockup_panic=1"
            ];

            boot.kernelModules = [ "iTCO_wdt" ]; # Intel boards

            systemd.settings.Manager = {
              KExecWatchdogSec = null;
              RebootWatchdogSec = "${ts (timeout * 2)}s"; # if unresponsive for this much time, reboot
              RuntimeWatchdogSec = "${ts timeout}s"; # system should ping at least this often
              WatchdogDevice = "/dev/watchdog"; # path to hardware watchdog
            };

            boot.crashDump.enable = true;
          };

          homeManager = {
            programs.zsh.shellAliases = {
              panic = "echo c | sudo tee /proc/sysrq-trigger";
            };
          };
        };
    };
}
