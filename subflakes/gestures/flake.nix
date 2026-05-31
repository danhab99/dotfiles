{
  description = "gestures";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "gestures";

    options =
      { lib }:
      with lib;
      {
        devicePath = mkOption {
          type = types.str;
        };
      };

    output =
      { pkgs, cfg, ... }:
      {
        packages = with pkgs; [
          libinput
          libinput-gestures
          wmctrl
          xdotool
        ];

        homeManager = {
          xsession.windowManager.i3.config.startup = [
            {
              command = "libinput-gestures --device \"${cfg.devicePath}\"";
              always = true;
            }
          ];

          home.file.".config/libinput-gestures.conf".source = pkgs.writeText "libinput-gestures.conf" ''
            gesture swipe up 3 i3-msg fullscreen enable
            gesture swipe down 3 i3-msg fullscreen disable
            gesture pinch clockwise xdotool key "Super_L+Shift+x"
            gesture pinch anticlockwise xdotool key "Super_L+Shift+x"
          '';
        };

        nixos = {
          services.libinput.enable = true;
        };
      };
  };
}
