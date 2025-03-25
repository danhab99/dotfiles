import ../module.nix
{
  name = "thinkpad";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    nixos = {
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
      };

    homeManager = { };
  };
}
