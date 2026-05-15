# mkMachineFlake: Builder for machine flakes
#
# Usage in machine/{name}/flake.nix:
#   mkMachineFlake {
#     name = "laptop";
#     system = "x86_64-linux";
#     enabledModuleInputs = { git = inputs.module-git; docker = inputs.module-docker; };
#     hostConfig = import ./configuration.nix;
#     hardwareConfigPath = ./hardware-configuration.nix;
#     inputs = inputs;
#     outputFn = null;  # Optional custom builder, e.g., nixos-uconsole.lib.mkUConsoleSystem
#   }
#
# Returns: { nixosConfigurations.{name} = nixosSystem; homeManagerModules = {...}; }

{ name
, system
, enabledModuleInputs
, hostConfig
, hardwareConfigPath
, inputs
, outputFn ? null
}:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  lib = inputs.nixpkgs.lib;

  # Destructure configuration.nix with defaults
  users = hostConfig.users or { };
  module = hostConfig.module or { };
  environmentVariables = hostConfig.environmentVariables or { };
  packages = hostConfig.packages or (p: [ ]);
  files = hostConfig.files or { };
  i3Config = hostConfig.i3Config or ({ mod }: { });
  xserver = hostConfig.xserver or "";
  bind = hostConfig.bind or [ ];
  jobs = hostConfig.jobs or (a: [ ]);
  aliases = hostConfig.aliases or (p: { });
  raw = hostConfig.raw or { };

  # ── Helpers ──────────────────────────────────────────────────────

  strLen = builtins.stringLength;

  mkJob =
    { name
    , script
    , schedule ? ""
    , packages ? [ ]
    , user ? "root"
    , timer ? ""
    }:
    let
      baseService = {
        services."${name}" = {
          enable = true;
          script = script;
          serviceConfig = {
            Type = "oneshot";
            User = user;
            Restart = "on-failure";
            RestartSec = 5;
          };
          path = packages;
        };
      };
      withTimer =
        if (strLen schedule > 0) || (strLen timer > 0) then
          let
            mkAddAttr = { key, val }: if strLen val > 0 then { "${key}" = val; } else { };
          in
          {
            timers."${name}" = {
              enable = true;
              wantedBy = [ "timers.target" ];
              timerConfig = {
                OnUnitActiveSec = "10min";
                Persistent = true;
              }
              // mkAddAttr {
                key = "OnCalendar";
                val = schedule;
              }
              // mkAddAttr {
                key = "OnTimer";
                val = timer;
              };
            };
          }
        else
          { };
    in
    baseService // withTimer;

  mkBind = { dest, dir }: "L+ /home/dan/${dir} - - - - /${dest}/${dir}";

  # ── Compose enabled modules into deferred module list ────────────

  # enabledModuleInputs is a mapping of module names to their flake outputs
  # We need to extract the nixosModules.default from each
  enabledModuleList = builtins.map (moduleName:
    let moduleOutput = enabledModuleInputs.${moduleName};
    in moduleOutput.nixosModules.default or moduleOutput.nixosModules.${moduleName} or (throw "Module ${moduleName} has no nixosModules output")
  ) (builtins.attrNames enabledModuleInputs);

  # ── The NixOS module for this host (base config + machine-specific) ──

  hostModule =
    { pkgs, lib, ... }:
    {
      imports = [
        (import ../../users)
      ];

      config = {
        inherit users module;

        services.fwupd.enable = true;

        environment.variables = environmentVariables;
        environment.systemPackages = packages pkgs;

        home-manager.backupFileExtension = "hm-backup";

        home-manager.users.dan = {
          home.file = files;
          xsession.windowManager.i3.config = i3Config { mod = "Mod4"; };
        };

        services = {
          xserver.config = xserver;
          dbus.enable = true;
          flatpak.enable = true;
        };

        systemd =
          let
            defs = jobs { inherit pkgs; };
            serviceTimers = map mkJob defs;
            services = map (x: x.services) serviceTimers;
            timers = map (x: x.timers) serviceTimers;

            merge = builtins.foldl' (a: b: a // b) { };

            allServices = merge services;
            allTimers = merge timers;

            finishedJobs = {
              services = allServices;
            }
            // {
              timers = allTimers;
            };
          in
          ({ tmpfiles.rules = map mkBind bind; } // finishedJobs);

        networking = {
          networkmanager.enable = true;
          hostName = name;
        };

        environment.localBinInPath = true;

        boot.tmp.cleanOnBoot = true;

        programs.zsh.shellAliases = (aliases pkgs);

        system.stateVersion = "24.05";
      };
    };

  # ── Compose all modules ──────────────────────────────────────────

  modules = [
    # All enabled dendritic modules
    { imports = enabledModuleList; }
    # Host-specific module
    hostModule
    # Hardware
    hardwareConfigPath
    # Cachix
    ../../cachix.nix
    # Overlays
    { nixpkgs.overlays = [
        inputs.openclaw.overlays.default
        inputs.nur.overlays.default
      ];
    }
    # Home-manager
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [
        inputs.openclaw.homeManagerModules.openclaw
        inputs.adirofi.homeManagerModules.default
      ];
    }
    # Machine raw config (escape hatch)
    raw
  ];

  # ── Build the system ─────────────────────────────────────────────

  defaultOutput = inputs.nixpkgs.lib.nixosSystem {
    inherit system modules;
    specialArgs = inputs;
  };

  builtSystem =
    if outputFn != null
    then outputFn system inputs modules
    else defaultOutput;
in
{
  nixosConfigurations.${name} = builtSystem;

  # Optionally expose homeManagerModules if needed externally
  homeManagerModules = builtins.foldl' (acc: moduleInput:
    acc // (moduleInput.homeManagerModules or { })
  ) { } (builtins.attrValues enabledModuleInputs);
}
