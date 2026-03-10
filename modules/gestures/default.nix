import ../module.nix {
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
        wtype # Wayland-native key/text injection
      ];

      homeManager = {
        wayland.windowManager.sway.config.startup = [
          {
            command = "libinput-gestures --device \"${cfg.devicePath}\"";
            always = true;
          }
        ];

        home.file.".config/libinput-gestures.conf".source = pkgs.writeText "libinput-gestures.conf" ''
          gesture swipe up 3 swaymsg fullscreen enable
          gesture swipe down 3 swaymsg fullscreen disable
          gesture pinch clockwise wtype -M logo -M shift -k x -m shift -m logo
          gesture pinch anticlockwise wtype -M logo -M shift -k x -m shift -m logo
        '';
      };

      nixos = {
        services.libinput.enable = true;
      };
    };
}
