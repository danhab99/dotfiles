{
  description = "thinkpad";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "thinkpad";

    options =
      { lib }:
      {
        enableLoudFan = lib.mkEnableOption "loud fan";
      };

    output =
      { pkgs
      , lib
      , cfg
      , ...
      }:
      let
        fanConfig = {
          startTemp = 45;
          fullSpeedTemp = 90;
          tempStep = 5;
          hysteresis = 5;
          minFanLevel = 2;
          maxFanLevel = 7;
          enableDisengaged = cfg.enableLoudFan;
        };

        generateFanLevels = config:
          let
            inherit (config) startTemp fullSpeedTemp tempStep hysteresis minFanLevel maxFanLevel enableDisengaged;

            numLevels = maxFanLevel - minFanLevel + 1;

            makeLevelEntry = idx:
              let
                fanLevel = minFanLevel + idx;
                upperTemp = startTemp + (idx * tempStep);
                lowerTemp = upperTemp - hysteresis;
              in
              [ fanLevel lowerTemp upperTemp ];

            intermediateLevels = lib.genList makeLevelEntry numLevels;

            offLevel = [ 0 0 startTemp ];
            disengagedLevel = [ 127 fullSpeedTemp 32767 ];

            finalLevel = if enableDisengaged then disengagedLevel else [ maxFanLevel (startTemp + ((numLevels - 1) * tempStep) - hysteresis) 32767 ];
          in
          [ offLevel ] ++ intermediateLevels ++ [ finalLevel ];

        fanLevels = generateFanLevels fanConfig;
      in
      {
        packages = with pkgs; [
          thinkfan
          lm_sensors
          brightnessctl
        ];

        homeManager = {
          programs.zsh.shellAliases = {
            fan-max = "fan disengaged";
          };

          xsession.windowManager.i3.config.keybindings = {
            "XF86MonBrightnessUp" = "exec brightnessctl set +10%";
            "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";
          };

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
        };

        nixos = {
          systemd.services.usb-power-management-disable = {
            description = "Disable USB power management for all devices to prevent dock disconnects";
            wantedBy = [ "multi-user.target" ];
            after = [ "systemd-udev-settle.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "${pkgs.bash}/bin/bash -c 'for dev in /sys/bus/usb/devices/*/power/control; do [ -f \"$dev\" ] && echo on > \"$dev\" 2>/dev/null || true; done'";
              ExecStartPost = "${pkgs.coreutils}/bin/sleep 2";
            };
          };

          systemd.timers.usb-power-management-enforce = {
            description = "Periodically re-enforce USB power management settings";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "1min";
              OnUnitActiveSec = "5min";
            };
          };

          systemd.services.usb-power-management-enforce = {
            description = "Re-enforce USB power management settings";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.bash}/bin/bash -c 'for dev in /sys/bus/usb/devices/*/power/control; do [ -f \"$dev\" ] && echo on > \"$dev\" 2>/dev/null || true; done'";
            };
          };

          services.xserver.videoDrivers = [
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

              USB_AUTOSUSPEND = 0;
              USB_DENYLIST = "0bda:0411 0bda:5411 05e3:0626 05e3:0610 1a40:0801";
              USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 1;
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
              ]
            ];
          };

          boot.extraModprobeConfig = ''
            options thinkpad_acpi fan_control=1
          '';

          module.zsh.extras = ''
            fan() {
              echo "level $1" | sudo tee /proc/acpi/ibm/fan
            }
          '';
        };
      };
  };
}
