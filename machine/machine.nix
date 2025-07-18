{ users
, module
, hostName
, environmentVariables ? { }
, packages ? pkgs: [ ]
, files ? { }
, i3Config ? { mod }: { }
, xserver ? ""
, bind ? [ ]
, jobs ? { pkgs }: [ ]
}:
let
  mkJob = { name, script, schedule, packages }: {
    services."${name}" = {
      script = script;

      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };

      path = packages;
    };

    timers."${name}" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = schedule;
        Persistent = true;
      };
    };
  };

  mkBind = { dest, dir }: "L+ /home/dan/${dir} - - - - /${dest}/${dir}";
in
{ pkgs, ... }:

{
  imports = [
    ../modules
    ../users
  ];

  config = {
    inherit users module;

    environment.variables = environmentVariables;
    environment.systemPackages = packages pkgs;

    home-manager.users.dan = {
      home.file = files;
      xsession.windowManager.i3.config = i3Config {
        mod = "Mod4";
      };
    };

    services.xserver.config = xserver;

    systemd = {
      tmpfiles.rules = map mkBind bind;
    } // builtins.foldl' (a: b: a // b) { } (map mkJob (jobs {
      inherit pkgs;
    }));

    networking = {
      networkmanager.enable = true;
      inherit hostName;
    };

    environment.localBinInPath = true;

    services.dbus.enable = true;

    services.flatpak.enable = true;
    xdg.portal.enable = true;

    boot.tmp.cleanOnBoot = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Please read the comment before changing.
  };
}
