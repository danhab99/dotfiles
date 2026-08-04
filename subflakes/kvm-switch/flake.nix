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
          ${builtins.readFile ../../scripts/disable-usb-suspend.sh}
        '';
      in
      {
        packages = with pkgs; [ ];

        nixos = {
          boot = {
            kernelParams = [
              "usbcore.autosuspend=-1"
              "nvme_core.default_ps_max_latency_us=0"
              "nvme_core.io_timeout=4294967295"
              "pci=noaer"
              "pcie_aspm=off"
              # Hub/dock USB: disable autosuspend (k). Includes Genesys, Realtek,
              # Terminus, VIA Labs (ThinkPad USB-C hub path), Lenovo TB3 dock.
              "usbcore.quirks=05e3:0626:k,05e3:0610:k,0bda:0411:k,0bda:5411:k,1a40:0801:k,2109:0817:k,2109:2817:k,2109:8887:k,17ef:307f:k,17ef:3080:k,17ef:3081:k,17ef:3082:k"
              # Stop i915 DP link from entering deep display C-states / PSR that
              # flap through KVM EDID emulation (Xorg "link-state is BAD" every ~2s).
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
            # Set power attrs directly. Do NOT RUN+= a script on usb change —
            # writing power/* generates more change events and cascades into
            # hub/KVM reset storms (flashing screens, dead input, clock jumps).
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="0"
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/persist", ATTR{power/persist}="1"

            # Thunderbolt/USB4: keep runtime PM off on the dock path.
            ACTION=="add", SUBSYSTEM=="thunderbolt", TEST=="power/control", ATTR{power/control}="on"
            ACTION=="add", SUBSYSTEM=="pci", DRIVER=="thunderbolt", TEST=="power/control", ATTR{power/control}="on"
          '';

          systemd.services.disable-usb-suspend = {
            description = "Disable USB autosuspend, wakeup, and USB3 LPM on all ports";
            wantedBy = [ "multi-user.target" ];
            after = [ "systemd-udev-settle.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = disableUsbSuspend;
            };
          };

          # Infrequent re-enforce only. Never on every USB uevent.
          systemd.timers.disable-usb-suspend-enforce = {
            description = "Periodically re-enforce USB no-suspend settings";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "1min";
              OnUnitActiveSec = "10min";
              AccuracySec = "30s";
            };
          };

          systemd.services.disable-usb-suspend-enforce = {
            description = "Re-enforce USB no-suspend settings";
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

          services.tlp.settings = {
            USB_AUTOSUSPEND = 0;
            USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 1;
            # mkForce: thinkpad also sets USB_DENYLIST; keep the KVM/dock set.
            USB_DENYLIST = lib.mkForce "0bda:0411 0bda:5411 05e3:0626 05e3:0610 1a40:0801 2109:0817 2109:2817 2109:8887 17ef:307f 17ef:3080 17ef:3081 17ef:3082";
            RUNTIME_PM_ON_AC = "on";
            RUNTIME_PM_ON_BAT = "on";
            PCIE_ASPM_ON_AC = "performance";
            PCIE_ASPM_ON_BAT = "performance";
          };
        };
      };
  };
}
