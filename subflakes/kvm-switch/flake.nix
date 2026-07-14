{
  description = "kvm-switch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "kvm-switch";

    options = { lib, ... }: with lib; { };

    output = { pkgs, ... }:
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
              "usbcore.quirks=05e3:0626:k,05e3:0610:k,0bda:0411:k,0bda:5411:k,1a40:0801:k"
            ];

            extraModprobeConfig = ''
              options usbcore autosuspend=-1
              options xhci_hcd quirks=0x800
            '';
          };

          services.udev.extraRules = ''
            # Silent prevention only: sysfs power attrs, no display/input recovery scripts.
            ACTION=="add|change", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
            ACTION=="add|change", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
            ACTION=="add|change", SUBSYSTEM=="usb", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="0"
            ACTION=="add|change", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
            ACTION=="add|change", SUBSYSTEM=="usb", TEST=="power/persist", ATTR{power/persist}="1"
            ACTION=="add|change", SUBSYSTEM=="usb", RUN+="${disableUsbSuspend}"
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

          systemd.timers.disable-usb-suspend-enforce = {
            description = "Periodically re-enforce USB no-suspend settings";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "30sec";
              OnUnitActiveSec = "1min";
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
            USB_DENYLIST = "0bda:0411 0bda:5411 05e3:0626 05e3:0610 1a40:0801";
          };
        };
      };
  };
}
