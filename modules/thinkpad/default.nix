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
    };
  };
}
