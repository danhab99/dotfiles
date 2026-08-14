{
  description = "kvm-switch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "kvm-switch";

    options = { lib, ... }: with lib; { };

    output = { pkgs, lib, ... }:
      let
        disableUsbSuspend = pkgs.writeShellScript "disable-usb-suspend" ''
          export PATH="${lib.makeBinPath [
            pkgs.coreutils
            pkgs.findutils
            pkgs.util-linux
            pkgs.gnugrep
          ]}:$PATH"
          ${builtins.readFile ../../scripts/disable-usb-suspend.sh}
        '';

        xInputGuard = pkgs.writeShellScript "x-input-guard" ''
          export PATH="${lib.makeBinPath [
            pkgs.xorg.xinput
            pkgs.coreutils
            pkgs.gnused
            pkgs.gnugrep
            pkgs.procps
            pkgs.bash
          ]}:$PATH"
          set -uo pipefail
          while true; do
            bash ${../../scripts/reattach-x-inputs.sh} || true
            sleep 0.5
          done
        '';

        seizureWatchdog = pkgs.writeShellScript "display-seizure-watchdog" ''
          export PATH="${lib.makeBinPath [
            pkgs.xorg.xinput
            pkgs.xorg.xrandr
            pkgs.coreutils
            pkgs.gnused
            pkgs.gnugrep
            pkgs.procps
            pkgs.bash
            pkgs.util-linux
            pkgs.systemd
            pkgs.sudo
          ]}:$PATH"
          exec bash ${../../scripts/display-seizure-watchdog.sh} watch
        '';
      in
      {
        packages = with pkgs; [ ];

        homeManager = {
          home.file.".config/autostart/xfsettingsd.desktop".text = ''
            [Desktop Entry]
            Hidden=true
          '';
          home.file.".local/bin/xfsettingsd" = {
            executable = true;
            text = ''
              #!/bin/sh
              # tradezero: real xfsettingsd fights dock layout / re-enables eDP.
              exec sleep infinity
            '';
          };

          systemd.user.services.x-input-guard = {
            Unit = {
              Description = "Reattach floating X input devices (KVM/USB hub)";
              After = [ "graphical-session-pre.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${xInputGuard}";
              Restart = "always";
              RestartSec = 1;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };

          systemd.user.services.display-seizure-watchdog = {
            Unit = {
              Description = "Soft-recover X display seizure (pegged CPU / eDP / compositor)";
              After = [ "graphical-session-pre.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${seizureWatchdog}";
              Restart = "always";
              RestartSec = 1;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        };

        nixos = {
          boot = {
            kernelParams = [
              "usbcore.autosuspend=-1"
              "nvme_core.default_ps_max_latency_us=0"
              "nvme_core.io_timeout=4294967295"
              "pci=noaer"
              "pcie_aspm=off"
              "usbcore.quirks=05e3:0626:k,05e3:0610:k,0bda:0411:k,0bda:5411:k,1a40:0801:k,2109:0817:k,2109:2817:k,2109:8887:k,17ef:307f:k,17ef:3080:k,17ef:3081:k,17ef:3082:k,3297:1969:k,05ac:0265:k"
              "i915.enable_psr=0"
              "i915.enable_fbc=0"
              "i915.enable_dc=0"
            ];

            extraModprobeConfig = ''
              options usbcore autosuspend=-1
              options xhci_hcd quirks=0x800
              options i915 enable_psr=0 enable_fbc=0 enable_dc=0
            '';
          };

          services.udev.extraRules = ''
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="0"
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/persist", ATTR{power/persist}="1"
            ACTION=="add", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", TEST=="power/control", ATTR{power/control}="on"
            ACTION=="add", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
            ACTION=="add", SUBSYSTEM=="thunderbolt", TEST=="power/control", ATTR{power/control}="on"
            ACTION=="add", SUBSYSTEM=="pci", DRIVER=="thunderbolt", TEST=="power/control", ATTR{power/control}="on"
          '';

          systemd.services.disable-usb-suspend = {
            description = "Disable USB autosuspend, wakeup, and USB3 LPM on all ports";
            wantedBy = [ "multi-user.target" ];
            after = [ "systemd-udev-settle.service" ];
            path = [
              pkgs.coreutils
              pkgs.findutils
              pkgs.util-linux
              pkgs.gnugrep
            ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = disableUsbSuspend;
            };
          };

          systemd.timers.disable-usb-suspend-enforce = {
            description = "Periodically re-enforce USB no-suspend settings";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "30s";
              OnUnitActiveSec = "2min";
              AccuracySec = "15s";
            };
          };

          systemd.services.disable-usb-suspend-enforce = {
            description = "Re-enforce USB no-suspend settings";
            path = [
              pkgs.coreutils
              pkgs.findutils
              pkgs.util-linux
              pkgs.gnugrep
            ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = disableUsbSuspend;
            };
          };

          systemd.services.reset-usb = {
            description = "Reset xHCI USB controller to recover from stuck devices";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "/bin/sh /etc/nixos/scripts/reset-usb.sh";
            };
          };

          systemd.services.display-seizure-escalate = {
            description = "Restart display-manager after failed soft seizure recovery";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.systemd}/bin/systemctl restart display-manager.service";
            };
          };

          # Root watchdog: when X is pegged with eDP on beside dock outputs,
          # user-session xrandr hangs and soft recover cannot clear the wedge.
          # This path only uses /proc + sysfs and restarts display-manager.
          systemd.services.display-seizure-system-watchdog = {
            description = "Root watchdog: restart display-manager on hard X seizure";
            wantedBy = [ "multi-user.target" ];
            after = [ "display-manager.service" ];
            path = [
              pkgs.coreutils
              pkgs.procps
              pkgs.gnugrep
              pkgs.gnused
              pkgs.gawk
              pkgs.bash
              pkgs.util-linux
              pkgs.systemd
            ];
            serviceConfig = {
              Type = "simple";
              ExecStart = pkgs.writeShellScript "display-seizure-system-watchdog" ''
                export PATH="${lib.makeBinPath [
                  pkgs.coreutils
                  pkgs.procps
                  pkgs.gnugrep
                  pkgs.gnused
                  pkgs.gawk
                  pkgs.bash
                  pkgs.util-linux
                  pkgs.systemd
                ]}:$PATH"
                exec bash ${../../scripts/display-seizure-system-watchdog.sh}
              '';
              Restart = "always";
              RestartSec = 2;
            };
          };

          security.sudo.extraRules = [
            {
              users = [ "dan" ];
              commands = [
                {
                  command = "/run/current-system/sw/bin/systemctl start display-seizure-escalate.service";
                  options = [ "NOPASSWD" ];
                }
                {
                  command = "/run/current-system/sw/bin/systemctl restart display-seizure-escalate.service";
                  options = [ "NOPASSWD" ];
                }
              ];
            }
          ];

          services.tlp.settings = {
            USB_AUTOSUSPEND = 0;
            USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 1;
            USB_DENYLIST = lib.mkForce "0bda:0411 0bda:5411 05e3:0626 05e3:0610 1a40:0801 2109:0817 2109:2817 2109:8887 17ef:307f 17ef:3080 17ef:3081 17ef:3082 3297:1969 05ac:0265";
            RUNTIME_PM_ON_AC = "on";
            RUNTIME_PM_ON_BAT = "on";
            PCIE_ASPM_ON_AC = "performance";
            PCIE_ASPM_ON_BAT = "performance";
          };
        };
      };
  };
}
