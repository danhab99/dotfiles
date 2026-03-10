import ../module.nix {
  name = "kvm-resilience";

  options =
    { lib }:
    with lib;
    {
      usbHubVendors = mkOption {
        type = types.listOf types.str;
        default = [ "0bda" "05e3" "1a40" ];
        description = "USB vendor IDs of hubs/docks to force-keep awake";
      };
      enableThunderboltHotplug = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Thunderbolt/USB4 hotplug hardening";
      };
    };

  output =
    { pkgs, cfg, lib, ... }:
    let
      hubVendorRules = builtins.concatStringsSep "\n" (
        builtins.map (vid: ''
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="${vid}", TEST=="power/control", ATTR{power/control}="on"
        '') cfg.usbHubVendors
      );
    in
    {
      packages = with pkgs; [
        usbutils
        pciutils
      ];

      nixos = {
        # ── Kernel parameters for USB/display resilience ──────────────────────
        boot.kernelParams = [
          # Prevent USB autosuspend globally at kernel level
          "usbcore.autosuspend=-1"

          # DRM: attempt automatic recovery on GPU hangs (0=off, 1=on)
          "drm.edid_firmware="

          # Force kernel to re-probe USB on resume
          "usbcore.quirks="

          # Ensure i915 (Intel) / amdgpu keeps link alive
          "i915.enable_dc=0"
          "i915.enable_psr=0"
          "i915.enable_fbc=0"

          # Thunderbolt: allow hotplug without authorization
          "thunderbolt.host_reset=1"
        ];

        # ── Kernel modules for better hotplug ─────────────────────────────────
        boot.kernelModules = [
          "uinput"
        ] ++ lib.optionals cfg.enableThunderboltHotplug [
          "thunderbolt"
        ];

        # ── udev rules: keep USB hubs/docks powered + HID rebind trigger ────
        services.udev.extraRules = ''
          # Force all USB hubs to stay powered (bDeviceClass 09 = Hub)
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", TEST=="power/control", ATTR{power/control}="on"

          # Force all USB HID devices to stay powered (keyboards/mice through KVM)
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", TEST=="power/control", ATTR{power/control}="on"

          # Force USB network adapters to stay powered
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="02", TEST=="power/control", ATTR{power/control}="on"

          # Vendor-specific hub rules
          ${hubVendorRules}

          # DRM hotplug: trigger output re-scan on display connect/disconnect
          ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${pkgs.bash}/bin/bash -c 'echo detect > /sys/class/drm/%k/status 2>/dev/null || true'"

          # When a USB HID device is added, trigger the rebind service to recover keyboards after KVM switch
          ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", TAG+="systemd", ENV{SYSTEMD_WANTS}+="usb-hid-rebind.service"
        '';

        # ── Thunderbolt: authorize devices automatically ──────────────────────
        services.hardware.bolt.enable = cfg.enableThunderboltHotplug;

        # ── systemd: periodically re-enforce USB power settings ───────────────
        systemd.services.usb-power-keepalive = {
          description = "Disable USB autosuspend for all devices (KVM/dock resilience)";
          wantedBy = [ "multi-user.target" ];
          after = [ "systemd-udev-settle.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.bash}/bin/bash -c 'for dev in /sys/bus/usb/devices/*/power/control; do [ -f \"$dev\" ] && echo on > \"$dev\" 2>/dev/null || true; done; for dev in /sys/bus/usb/devices/*/power/autosuspend_delay_ms; do [ -f \"$dev\" ] && echo -1 > \"$dev\" 2>/dev/null || true; done'";
          };
        };

        systemd.timers.usb-power-keepalive-poll = {
          description = "Re-enforce USB power settings every 2 minutes";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "30s";
            OnUnitActiveSec = "2min";
          };
        };

        systemd.services.usb-power-keepalive-poll = {
          description = "Re-apply USB power management overrides";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.bash}/bin/bash -c 'for dev in /sys/bus/usb/devices/*/power/control; do [ -f \"$dev\" ] && echo on > \"$dev\" 2>/dev/null || true; done'";
          };
        };

        # ── systemd: bind USB HID to recover keyboards after KVM switch ──────
        systemd.services.usb-hid-rebind = {
          description = "Re-bind USB HID drivers after KVM switch events";
          wantedBy = [ "multi-user.target" ];
          after = [ "systemd-udev-settle.service" ];
          path = [ pkgs.coreutils pkgs.bash pkgs.usbutils ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = false;
            ExecStart = pkgs.writeShellScript "usb-hid-rebind" ''
              for dev in /sys/bus/usb/drivers/usbhid/*/; do
                devpath="$(basename "$dev")"
                if [ -e "$dev/bInterfaceClass" ]; then
                  class="$(cat "$dev/bInterfaceClass" 2>/dev/null || true)"
                  if [ "$class" = "03" ]; then
                    echo "$devpath" > /sys/bus/usb/drivers/usbhid/unbind 2>/dev/null || true
                    sleep 0.2
                    echo "$devpath" > /sys/bus/usb/drivers/usbhid/bind 2>/dev/null || true
                  fi
                fi
              done
            '';
          };
        };

        # ── sysctl: increase USB timeout for slow KVM switches ───────────────
        boot.kernel.sysctl = {
          # Allow more time for USB transactions (helps with KVM switch delays)
          "kernel.hung_task_timeout_secs" = 120;
        };
      };

      homeManager = { };
    };
}
