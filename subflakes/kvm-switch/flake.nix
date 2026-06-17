{
  description = "kvm-switch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "kvm-switch";

    options = { lib, ... }: with lib; { };

    output = { pkgs, ... }: {
      packages = with pkgs; [

      ];

      nixos = {
        # Disable USB autosuspend to prevent KVM switch power interruptions from
        # putting devices into an unrecoverable state (usb_set_interface -110 loop).
        boot.kernelParams = [
          "usbcore.autosuspend=-1"
          # NVMe resilience: disable power saving states to prevent hangs on a
          # flaky drive controller, and max out I/O timeout so a slow/dying drive
          # doesn't trigger a kernel panic or force a reset mid-session.
          "nvme_core.default_ps_max_latency_x=0"
          "nvme_core.io_timeout=4294967295"
          # PCIe resilience: disable AER so errors from a bad device don't cause
          # machine-check exceptions, and disable ASPM so the PCIe link never
          # enters a low-power state that a flaky device might not wake from.
          "pci=noaer"
          "pcie_aspm=off"
        ];

        # Disable runtime power management for USB hubs (prevents KVM/audio disconnects)
        services.udev.extraRules = ''
          # Disable autosuspend for ALL USB hubs
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", TEST=="power/control", ATTR{power/control}="on"
          # GenesysLogic USB hubs (KVM switch hubs)
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", TEST=="power/control", ATTR{power/control}="on"
          # Feixiang USB HIFI Audio - disable autosuspend to prevent timeout storms
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="262a", TEST=="power/control", ATTR{power/control}="on"
        '';

        # Systemd service for on-demand USB controller reset
        systemd.services.reset-usb = {
          description = "Reset xHCI USB controller to recover from stuck devices";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "/bin/sh /etc/nixos/scripts/reset-usb.sh";
          };
        };

        tlp.settings = {
          USB_AUTOSUSPEND = 0;
          USB_DENYLIST = "0bda:0411 0bda:5411 05e3:0626 05e3:0610 1a40:0801";
        };

        udev.extraRules = ''
          # Disable autosuspend for ALL USB hubs (prevents KVM/display disconnects)
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", TEST=="power/control", ATTR{power/control}="on"

          # Disable autosuspend for USB network adapters
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="02", TEST=="power/control", ATTR{power/control}="on"

          # Specifically target your GenesysLogic hubs by vendor ID
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", TEST=="power/control", ATTR{power/control}="on"

          # Target Realtek USB hubs (your USB3.2/2.1 hubs)
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", TEST=="power/control", ATTR{power/control}="on"

          # Target VLI hubs
          ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="1a40", TEST=="power/control", ATTR{power/control}="on"

          # Disable runtime power management for ALL USB devices under your dock path
          ACTION=="add|change", SUBSYSTEM=="usb", DEVPATH=="*3-1*", TEST=="power/control", ATTR{power/control}="on"
          ACTION=="add|change", SUBSYSTEM=="usb", DEVPATH=="*2-3*", TEST=="power/control", ATTR{power/control}="on"

          # Re-apply monitor layout on display hotplug/link reset
          ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.autorandr}/bin/autorandr -c"
        '';
      };
    };
  };
}
