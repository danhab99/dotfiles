import ../module.nix
{
  name = "thinkpad";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      displaylink
    ];

    nixos = {
      services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

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

      # services.tlp = {
      #   enable = true;
      #   settings = {
      #     CPU_BOOST_ON_AC = 1;
      #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
      #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      #     CPU_BOOST_ON_BAT = 1;
      #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      #     CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      #   };
      # };

      services.hardware.bolt.enable = true;

      # boot.extraModulePackages = with pkgs; [ linuxPackages.r8152 linuxPackages.ax88179_178a ];

      services.upower.enable = true;
      # services.power-profiles-daemon.enable = true;

      services.logind.settings = {
        Login = {
          IdleAction = "suspend";
          IdleActionSec = "15min";
        };
      };

      services.tlp.enable = true;
      services.tlp.settings = {
        # Battery vs AC profiles
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # Sleep configuration
        SUSPEND_MODULES = "snd_hda_intel"; # optional, speeds up suspend/resume

        # ThinkPad battery thresholds (if supported)
        START_CHARGE_THRESH_BAT0 = 20;
        STOP_CHARGE_THRESH_BAT0 = 95;

        # Enable autosuspend for USB devices when on battery
        USB_AUTOSUSPEND = 1;
      };
    };
  };
}
