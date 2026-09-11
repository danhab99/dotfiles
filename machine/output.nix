# machine.nix — Dendritic host builder
#
# Called from flake.nix as:
#   mkHost = import ./machine/machine.nix;
#   mkHost { inherit inputs allNixosModules; hostCfg = import ./configuration.nix; }
#
# Each machine/<hostName>/configuration.nix returns a plain attrset describing the host.

inputs:
{ hardware-configuration, hostCfg }:

let
  # Destructure with defaults
  hostName = hostCfg.name;
  system = hostCfg.system or "x86_64-linux";
  users = hostCfg.users or { };
  module = hostCfg.module or { };
  environmentVariables = hostCfg.environmentVariables or { };
  packages = hostCfg.packages or (pkgs: [ ]);
  files = hostCfg.files or { };
  raw = hostCfg.raw or { };
  outputFn = hostCfg.output or null;

  # ── The NixOS module for this host (base config + machine-specific) ──

  hostModule =
    { pkgs, lib, ... }:
    {
      imports = [
        ../users
      ];

      config = {
        inherit users module;

        services.fwupd.enable = true;

        environment.variables = environmentVariables;
        environment.systemPackages = packages pkgs;

        home-manager.backupFileExtension = "hm-backup";

        home-manager.users.dan = {
          home.file = files;
        };

        services = {
          dbus.enable = true;
          flatpak.enable = true;
        };

        networking = {
          networkmanager.enable = true;
          hostName = hostName;
        };

        environment.localBinInPath = true;

        boot.tmp.cleanOnBoot = true;

        system.stateVersion = "24.05";
      };
    };

  # ── Compose all modules ──────────────────────────────────────────

  modules = [
    # All dendritic modules (collected from flake.modules.nixos)
    (import ../get.nix inputs (
      i:
      if builtins.hasAttr "nixosModules" i && builtins.hasAttr "subflake" i.nixosModules
      then i.nixosModules.subflake
      else null
    ))

    # Host-specific module
    hostModule

    # Hardware
    hardware-configuration

    # Machine raw config (escape hatch)
    raw
  ];

  # ── Build the system ─────────────────────────────────────────────

  defaultOutput = inputs.nixpkgs.lib.nixosSystem {
    inherit system modules;
    specialArgs = inputs;
  };
in
if outputFn != null
then outputFn system inputs modules
else defaultOutput
