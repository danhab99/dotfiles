{
  description = "systemd-jobs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "systemd-jobs";

    options = { lib, ... }: with lib; {
      jobs = mkOption {
        default = { pkgs }: [ ];
        description = ''
          Function `{ pkgs }: [ { name, script, schedule ? "", packages ? [ ], user ? "root", timer ? "" } ]`
          describing oneshot systemd services, each optionally paired with a
          matching timer (when `schedule` or `timer` is non-empty).
        '';
      };
    };

    output = { pkgs, cfg, ... }:
      let
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
                inherit script;
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

        defs = map mkJob (cfg.jobs { inherit pkgs; });
        merge = builtins.foldl' (a: b: a // b) { };
      in
      {
        nixos = {
          systemd.services = merge (map (x: x.services) defs);
          systemd.timers = merge (map (x: x.timers or { }) defs);
        };
      };
  };
}
