import ../module.nix {
  name = "thinkpad";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        displaylink
        thinkfan
        fancontrol-gui
        lm_sensors
      ];

      homeManager = {
        home.file = {
          ".config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml" = {
            text = ''
              <?xml version="1.1" encoding="UTF-8"?>

              <channel name="xfce4-power-manager" version="1.0">
                <property name="xfce4-power-manager" type="empty">
                  <property name="brightness-switch-restore-on-exit" type="int" value="1"/>
                  <property name="brightness-switch" type="int" value="0"/>
                  <property name="show-tray-icon" type="bool" value="true"/>
                  <property name="critical-power-level" type="uint" value="4"/>
                  <property name="dpms-on-ac-sleep" type="uint" value="0"/>
                  <property name="dpms-on-ac-off" type="uint" value="0"/>
                  <property name="dpms-enabled" type="bool" value="false"/>
                  <property name="critical-power-action" type="uint" value="4"/>
                </property>
              </channel>
            '';
          };
        };

        systemd.user.services.dpms-killer = {
          Unit = {
            Description = "Continuously disable DPMS to prevent screens from turning off";
            Afte = [ "graphical-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = "${pkgs.bash}/bin/bash -c 'export DISPLAY=:0; while true; do ${pkgs.xorg.xset}/bin/xset -dpms; ${pkgs.xorg.xset}/bin/xset s off; ${pkgs.xorg.xset}/bin/xset s noblank; sleep 5; done'";
            Restart = "always";
            RestartSec = "3";
          };

          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };

        systemd.user.services.screen-monitor = {
          Unit = {
            Description = "Monitor and auto-enable screens if they turn off";
            After = [ "graphical-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = "${pkgs.bash}/bin/bash -c 'while true; do if xrandr | grep -q \" connected\" && ! xrandr --listactivemonitors | grep -q \"Monitors: [1-9]\"; then sleep 5; if xrandr | grep -q \" connected\" && ! xrandr --listactivemonitors | grep -q \"Monitors: [1-9]\"; then xrandr --auto; fi; fi; sleep 2; done'";
            Restart = "always";
            RestartSec = "5";
          };

          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };

      nixos = {
        services.xserver.videoDrivers = [
          "displaylink"
          "modesetting"
        ];

        services.udev.packages =
          let
            hwdbText = ''
              evdev:name:ThinkPad Extra Buttons:dmi:bvn*:bvr*:bd*:svnLENOVO*:pn*:*
               KEYBOARD_KEY_4b=playpause
               KEYBOARD_KEY_4c=nextsong
               KEYBOARD_KEY_4d=previoussong
            '';
          in
          [
            (pkgs.runCommand "thinkpad-hwdb" { } ''
              mkdir -p $out/lib/udev/hwdb.d
              echo "${hwdbText}" > $out/lib/udev/hwdb.d/99-thinkpad-xf86.hwdb
            '')
          ];

        programs.light = {
          enable = true;
          brightnessKeys.enable = true;
        };

        powerManagement = {
          enable = true;
          cpuFreqGovernor = "performance";
        };

        services.tlp = {
          enable = true;
          settings = {
            CPU_BOOST_ON_AC = 1;
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
            CPU_BOOST_ON_BAT = 1;
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
          };
        };

        services.hardware.bolt.enable = true;

        services.thinkfan = {
          enable = true;

          sensors = [
            {
              type = "hwmon";
              query = "/sys/class/hwmon/hwmon*/temp*_input";
            }
          ];

          fans = [
            {
              type = "tpacpi";
              query = "/proc/acpi/ibm/fan";
            }
          ];

          levels = [
            [
              0
              0
              55
            ]
            [
              1
              50
              60
            ]
            [
              2
              55
              65
            ]
            [
              3
              60
              70
            ]
            [
              4
              65
              75
            ]
            [
              5
              70
              80
            ]
            [
              6
              75
              85
            ]
            [
              7
              80
              90
            ]
            [
              127
              85
              32767
            ] # # disengaged
          ];
        };

        boot.extraModprobeConfig = ''
          options thinkpad_acpi fan_control=1
        '';

        # boot.extraModulePackages = with pkgs; [ linuxPackages.r8152 linuxPackages.ax88179_178a ];

        # services.upower.enable = true;
        # services.power-profiles-daemon.enable = true;

        # services.logind.settings = {
        #   IdleAction = "ignore";
        #   IdleActionSec = "0";
        # };

        # services.tlp.enable = true;
        # services.tlp.settings = {
        #   # Battery vs AC profiles
        #   CPU_SCALING_GOVERNOR_ON_AC = "performance";
        #   CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        #   # Sleep configuration
        #   SUSPEND_MODULES = "snd_hda_intel"; # optional, speeds up suspend/resume

        #   # ThinkPad battery thresholds (if supported)
        #   START_CHARGE_THRESH_BAT0 = 20;
        #   STOP_CHARGE_THRESH_BAT0 = 95;

        #   # Enable autosuspend for USB devices when on battery
        #   USB_AUTOSUSPEND = 1;
        # };
      };
    };
}
