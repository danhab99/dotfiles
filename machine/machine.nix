{ users
, module
, hostName
, environmentVariables ? { }
, packages ? (pkgs: [ ])
, files ? { }
, i3Config ? { mod }: { }
, xserver ? ""
, bind ? [ ]
, jobs ? (args: [ ])
, nixos ? { }
}:
let
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
          script = script;
          serviceConfig = {
            Type = "simple";
            User = user;
            Restart = "on-failure"; # Restart only when the service fails
            RestartSec = 5; # Wait 5 seconds before restarting
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
            timers."${name}" = (
              {
                wantedBy = [ "timers.target" ];
                timerConfig = {
                  OnUnitActiveSec = "10min";
                  Persistent = true;
                }
                // mkAddAttr { key = "OnCalendar"; val = schedule; }
                // mkAddAttr { key = "OnTimer"; val = timer; };
              }
            );
          }
        else { };
    in
    baseService // withTimer;

  mkBind = { dest, dir }: "L+ /home/dan/${dir} - - - - /${dest}/${dir}";
in
inputs@{ pkgs, ... }:
{
  imports = [
    (import ../modules/nixos.nix inputs)
    ../users
  ];

  config = {
    inherit users module;

    environment.variables = environmentVariables;
    environment.systemPackages = packages pkgs;

    home-manager.users.dan = {
      home.file = files;
      xsession.windowManager.i3.config = i3Config { mod = "Mod4"; };
    };

    services = {
      xserver.config = xserver;
      dbus.enable = true;
      flatpak.enable = true;
    } // (nixos.services or { });

    systemd = (
      { tmpfiles.rules = map mkBind bind; }
      // builtins.foldl' (a: b: a // b) { } (map mkJob (jobs { inherit pkgs; }))
    );

    networking = {
      networkmanager.enable = true;
      inherit hostName;
    };

    environment.localBinInPath = true;

    xdg.portal.enable = true;

    boot.tmp.cleanOnBoot = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Please read the comment before changing.

    nixpkgs.config.permittedInsecurePackages = [
      "libsoup-2.74.3"
    ];
  };
}
