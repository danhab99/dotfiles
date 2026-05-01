# machine.nix — Dendritic host builder
#
# Called from flake.nix as:
#   mkHost = import ./machine/machine.nix { inherit inputs allNixosModules; };
#   mkHost "laptop"  =>  nixosSystem for laptop
#
# Each machine/<hostName>/configuration.nix returns a plain attrset describing the host.

{ inputs, allNixosModules }:

hostName:
let
  # Import the machine's configuration.nix which returns a plain attrset
  hostCfg = import ./${hostName}/configuration.nix;

  # Destructure with defaults
  system = hostCfg.system or "x86_64-linux";
  users = hostCfg.users or { };
  module = hostCfg.module or { };
  environmentVariables = hostCfg.environmentVariables or { };
  packages = hostCfg.packages or (pkgs: [ ]);
  files = hostCfg.files or { };
  i3Config = hostCfg.i3Config or ({ mod }: { });
  xserver = hostCfg.xserver or "";
  bind = hostCfg.bind or [ ];
  jobs = hostCfg.jobs or (args: [ ]);
  aliases = hostCfg.aliases or (pkgs: { });
  raw = hostCfg.raw or { };
  outputFn = hostCfg.output or null;

  # ── Helpers ──────────────────────────────────────────────────────

  strLen = builtins.stringLength;

  mkJob =
    { name
    , script
    , schedule ? ""
    , packages ? [ ]
    , user ? "root"
    , timer ? ""
    ,
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
          ({ tmpfiles.rules = map mkBind bind; } // (finishedJobs));

        networking = {
          networkmanager.enable = true;
          hostName = hostName;
        };

        environment.localBinInPath = true;

        boot.tmp.cleanOnBoot = true;

        programs.zsh.shellAliases = (aliases pkgs);

        system.stateVersion = "24.05";
      };
    };

  # ── Compose all modules ──────────────────────────────────────────

  openclaw = inputs.openclaw;
  adirofi = inputs.adirofi;
  home-manager = inputs.home-manager;
  nixos-cli = inputs.nixos-cli;
  puppy = inputs.puppy;

  modules = [
    # All dendritic modules (collected from flake.modules.nixos)
    { imports = allNixosModules; }
    # Host-specific module
    hostModule
    # Hardware
    ./${hostName}/hardware-configuration.nix
    # Cachix
    ../cachix.nix
    # Overlays
    { nixpkgs.overlays = [
        openclaw.overlays.default
        inputs.nur.overlays.default
      ];
    }
    # Home-manager
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [
        openclaw.homeManagerModules.openclaw
        adirofi.homeManagerModules.default
      ];
    }
    # nixos-cli
    nixos-cli.nixosModules.nixos-cli

    puppy.nixosModules.default

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
