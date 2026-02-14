import ../module.nix
{
  name = "ev-cmd";

  options = { lib }: with lib; {
    configPath = mkOption { };
    devicePath = mkOption { };
    deviceName = mkOption { };
  };

  output = { pkgs, ev-cmd, cfg, ... }: {

    packages = with pkgs; [
      ev-cmd.packages.x86_64-linux.default
    ];

    homeManager = {
      xsession.windowManager.i3.config.startup = [
        {
          command = "systemctl --user import-environment DISPLAY XAUTHORITY XDG_SESSION_TYPE WAYLAND_DISPLAY";
          always = true;
        }
        {
          command = "xinput disable $$(xinput list --id-only '${cfg.deviceName}')";
          always = true;
        }
      ];

      systemd.user.services.ev-cmd = {
        Unit = {
          Description = "EV cmd";
          After = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";

          # # Explicitly set environment required for X
          # Environment = [
          #   "DISPLAY=:0"
          #   "XAUTHORITY=%h/.Xauthority"
          # ];

          # Use full path to avoid PATH issues
          # ExecStart = "${ev-cmd.packages.x86_64-linux.default}/bin/ev-cmd --device-path /dev/input/by-id/usb-LingYao_ShangHai_Thumb_Keyboard_081820131130-event-kbd --config-path ${cfg.configPath}";
          ExecStart = pkgs.writeShellScript "ev-cmd-wrapper" ''
            echo display = $DISPLAY
            echo Xauthority = $XAUTHORITY

            echo ==========

            env

            echo ==========

            ${ev-cmd.packages.x86_64-linux.default}/bin/ev-cmd --device-path ${cfg.devicePath} --config-path ${cfg.configPath}
          '';

          Restart = "on-failure";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

    nixos = { };
  };
}
